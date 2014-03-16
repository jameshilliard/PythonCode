/*******************************************************
* Author        :  Alex 
* Description   :
*   This tool is used to set switch board.
*
*
* History       :
*   DATE        |   REV     | AUTH      | INFO
*26 Jun 2012    |   1.0.0   | Alex      | Inital Version
*28 Jun 2012    |   1.0.1   | Jerry     | Add multiple dev support
*********************************************************/
char *REV = "1.0.1";
char *TIME = "28 Jun 2012";

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/types.h>
#include <sys/stat.h>  
#include <fcntl.h>
#include <termios.h>
#include <errno.h>

#define DEVICE "/dev/ttyS0"
#define BAUDRATE B38400
//#define BAUDRATE B115200

#define UARTPKT_HDR_A 0x48
#define UARTPKT_HDR_B 0x44
#define UARTPKT_TAIL_A 0x54
#define UARTPKT_TAIL_B 0x4C

#define ON 0x01
#define OFF 0x00
#define CHAR_BIT 8
#define BUFSIZE 10

#define RT_SUCCESS 0
#define RT_FALSE -1


//Command from host to board
enum {
    UCMD_SET_SW = 0x31,
    UCMD_GET_SW,
    UCMD_SET_ALL,
    UCMD_GET_ALL,
    UCMD_SET_FLSH
};

//Command from board to host
enum {
    UEVT_RCV_OK = 0x31,
    UEVT_RCV_ERR,
    UEVT_SW_STAT,
    UEVT_SW_ALL
};


int verbose = 0;

/*date struct used to save the state received from mcu*/
typedef struct rc_body{
    char event;
    char param1;
    char param2;
    int cherr;
} rc_body;

/*switch define*/
enum {
    S_LINE1 = 0x1,
    S_LINE2,
    S_DSL,
    S_BONDING,
    S_ETHERNET,
    S_USB1,
    S_USB2,
    S_DUT_POWER,
    S_AC_POWER1,
    S_AC_POWER2,
    S_AC_POWER3,
    S_AC_POWER4
};

enum {
    UPKT_HDRA = 0,
    UPKT_HDRB,
    UPKT_BODY,
    UPKT_SUM,
    UPKT_TAILA,
    UPKT_TAILB
};

/*print a char by binary format*/
int binary_print(char ch)
{
    int i=0;
    unsigned int mark=1<<CHAR_BIT*sizeof(char)-1;
    while (mark)
    {
        putchar(ch&mark?'1':'0');
        if (++i%4==0) putchar(' ');
        mark>>=1;
    }
    putchar('\n');
    return 0;
}

/*print a char by Hex format*/
int hex_print(unsigned char *pch,int len)
{
    int i;
    for(i = 0; i < len; i++)
    {
        printf(" 0x%x",*pch++);
    }
    printf("\n");
    return 0;
}

/*
int dec2hex(int n,char *buf)
{
    int i = 0;
    int mod;

    while(n)
    {
        mod = n % 16;
        if(mod >= 10 && mod <= 15)
        {
            buf[i++] = 'A' + mod - 10;
        }
        else
        {
            buf[i++] = mod;
        }
        n = n / 16;
    }
}
*/

/*set serial sevice option*/
int set_opt(int fd, int nSpeed, int nBits, char nEvent, int nStop)
{
    struct termios oldtio,newtio;
    
    if( tcgetattr(fd,&oldtio) != 0 )
    {
        perror("SetupSerial 1");
        return -1;
    }
    
    bzero(&newtio,sizeof(struct termios));
    newtio.c_cflag |= CLOCAL | CREAD;
    newtio.c_cflag &= ~CSIZE;
    
    switch(nBits)
    {
        case 7:
            newtio.c_cflag |= CS7;
            break;
        case 8:
            newtio.c_cflag |= CS8;
            break;
    }
    
    switch(nEvent)
    {
        case '0':
            newtio.c_cflag |= PARENB;
            newtio.c_cflag |= PARODD;
            newtio.c_iflag |= (INPCK | ISTRIP);
            break;
        case 'E':
            newtio.c_cflag |= PARENB;
            newtio.c_cflag |= ~PARODD;
            newtio.c_iflag |= (INPCK | ISTRIP);
            break;
        case 'N':
            newtio.c_cflag |= ~PARENB;
            break;
    }

    newtio.c_cflag &= ~CRTSCTS;
    
    cfsetispeed(&newtio, nSpeed);
    cfsetospeed(&newtio, nSpeed);
    
    if(nStop == 1)
    {
        newtio.c_cflag &= ~CSTOPB;
    }
    else if(nStop == 2)
    {
        newtio.c_cflag &= CSTOPB;
    }
    
    /*  initialize control characters*/
    newtio.c_cc[VTIME] = 5; /* inter-character timer, timeout VTIME*0.1 */
    newtio.c_cc[VMIN] = 0; /* blocking read until VMIN character arrives */
    
    tcflush(fd,TCIFLUSH);
    
    if((tcsetattr(fd, TCSANOW, &newtio)) != 0)
    {
        perror("com set error");
        return -1;
    }
    printf("set done!\n");
    return 0;
}//end set_opt();


/*open serial port*/
int open_port(int fd, char *serial_dev)
{
    /*open the serial port to read and write*/
    if ((fd = open(serial_dev, O_RDWR | O_NOCTTY))<0)   // | O_NDELAY);
    {
        perror("can't open serial port!\n");
        return -1;
    }
    
    if(fcntl(fd,F_SETFL,0) < 0)
    {
        printf("fcntl failed!\n");
        return -1;
    }
    else
    {
        printf("fcntl=%d\n",fcntl(fd,F_SETFL,0));
    }
    
    if(isatty(STDIN_FILENO) == 0)
    {
        printf("AT_WARNING : standard input is not terminal device\n");
        //return -1;
    }
    else
    {
        printf("isatty success!\n");
    }
    
    printf("fd-open=%d\n",fd);
    return fd;
}//end open_port();


int receive_from_mcu(int fd, rc_body *ptr)
{
    int i = 0, nread;
    unsigned char byte;
    unsigned char body[4]={0};
    int end = 1;
    char pk_status = UPKT_HDRA;


    printf("receive from switch board start:\n");
    tcflush(fd,TCIFLUSH);
    printf("Receive data= ");
    do
    {
        //if((nread = read(fd,&byte,1)) != 1)
        nread = read(fd,&byte,1);
        if(nread != 1 && nread != 0) 
        {
            printf("\nnread=%d,0x%x\n", nread, byte);
            perror("read failed or Serial connection wrong");
            return -1;
        }
        
        if(nread == 0) 
        {
            printf("\nnread=%d,0x%x\n", nread, byte);
            return 1; //no data get
        }

        printf(" 0x%x", byte);
        switch(pk_status)
        {
            case UPKT_HDRA:
                if(byte == UARTPKT_HDR_A)
                {
                    pk_status = UPKT_HDRB;
                }
                break;
            case UPKT_HDRB:
                if(byte == UARTPKT_HDR_B)
                {
                    pk_status = UPKT_BODY;
                }
                else if(byte == UARTPKT_HDR_A)
                {
                    pk_status = UPKT_HDRB;
                }
                else
                {
                    pk_status = UPKT_HDRA;
                }
                break;
            case UPKT_BODY:
                body[i++] = byte;
                if(i == 3)
                {
                    i = 0;
                    pk_status = UPKT_SUM;
                }
                break;
            case UPKT_SUM:
                body[3] = byte;
                //printf("command + parameter1 + parameter2 = 0x%x\n",(unsigned char)(body[0] +body[1] + body[2]));
                if(byte == (unsigned char)(body[0] +body[1] + body[2]))
                {
                    ptr->cherr = 0;
                }
                else
                {
                    ptr->cherr = 1;
                }
                pk_status = UPKT_TAILA;
                break;
            case UPKT_TAILA:
                if(byte == UARTPKT_TAIL_A)
                {
                    pk_status = UPKT_TAILB;
                }
                else if(byte == UARTPKT_HDR_A)
                {
                    pk_status = UPKT_HDRB;
                }
                else
                {
                    pk_status = UPKT_HDRA;
                }
                break;
            case UPKT_TAILB:
                if(byte == UARTPKT_TAIL_B)
                {
                    end = 0;
                }
                else if(byte == UARTPKT_HDR_A)
                {
                    pk_status = UPKT_HDRB;
                }
                else
                {
                    pk_status = UPKT_HDRA;
                }
                break;
            default:
                printf("unknown byte!\n");
                pk_status = UPKT_HDRA;
                break;
        }
    }while(end);
    
    printf("\nevent parameter1 parameter2 checksum\n");
    hex_print(body,4);

    if(ptr->cherr == 1)
    {
        printf("checksum error!\n");
        return -1;
    }
    
    ptr->event = body[0];
    ptr->param1 = body[1];
    ptr->param2 = body[2];
    printf("receive from switch board end.\n");
    return 0;
}//end receive_from_mcu();

int set_switch(int fd,char command,char param1,char param2)
{
    int i,nwrite,nread;
    int rt = RT_FALSE;
    unsigned char checksum, buf[BUFSIZE] = {0};
    rc_body state;

    memset(&state,sizeof(rc_body),0);

    checksum = (char)(command + param1 + param2);
    buf[0] = UARTPKT_HDR_A;
    buf[1] = UARTPKT_HDR_B;
    buf[2] = command;
    buf[3] = param1;
    buf[4] = param2;
    buf[5] = checksum;
    buf[6] = UARTPKT_TAIL_A;
    buf[7] = UARTPKT_TAIL_B;
    buf[8] = 0;

    printf("Send data by set:");
    hex_print(buf,8);
    
    for(i = 0; i < 3; i++)
    {
        tcflush(fd,TCOFLUSH);
        if((nwrite = write(fd,buf,8)) < 8)
        {
            printf("write failed!\n");
            return -1;
        }

        usleep(2000);

        if(receive_from_mcu(fd,&state) < 0)
        {
            printf("read switch failed!\n");
            return -1;
        }

        if(state.event == UEVT_RCV_OK)
        {
            rt = RT_SUCCESS;
            break;
        }
        else if(state.event == UEVT_RCV_ERR)
        {
            printf("set switch checksum error,try again!\n");
        }
        else
        {
            printf("set switch failed,try again!\n");
        }
    }
    
    return rt;
}//end set_switch();

int read_switch(int fd,char command,char param1,char param2,rc_body *pstate)
{
    int i,nwrite,nread;
    int rt = RT_FALSE;
    unsigned char buf[BUFSIZE] = {0};
    unsigned char checksum;


    memset(pstate,sizeof(rc_body),0);

    checksum = command + param1 + param2;
    buf[0] = UARTPKT_HDR_A;
    buf[1] = UARTPKT_HDR_B;
    buf[2] = command;
    buf[3] = param1;
    buf[4] = param2;
    buf[5] = checksum;
    buf[6] = UARTPKT_TAIL_A;
    buf[7] = UARTPKT_TAIL_B;
    buf[8] = 0;
    
    printf("Send data by read:");
    hex_print(buf,8);

    for(i = 0; i < 3; i++)
    {
        tcflush(fd,TCOFLUSH);
        if((nwrite = write(fd,buf,8)) < 8)
        {
            printf("write failed!\n");
            return -1;
        }
        
        usleep(2000);
        
        if(receive_from_mcu(fd,pstate) < 0)
        {
            printf("read switch failed!\n");
            return -1;
        }
        
        if(pstate->event == UEVT_SW_STAT || pstate->event == UEVT_SW_ALL)
        {
            rt = RT_SUCCESS;
            printf("rt=%d\n",rt);
            break;
        }
        else if(pstate->event == UEVT_RCV_ERR)
        {
            printf("get switch command transmit to MCU error,try to resend!\n");
        }
        else
        {
            printf("get switch command receive a wrong reply!\n");
        }
    }
    
    if(command == UCMD_GET_SW)
    {
        printf("switch%d status: %d\n",pstate->param1,pstate->param2);
    }
    if(command == UCMD_GET_ALL)
    {
        printf("switch16~switch9 status:\n");
        binary_print(pstate->param1);
        printf("switch8~switch1 status:\n");
        binary_print(pstate->param2);
    }
    return rt;
}//end read_switch();

int off_all_line(int fd)
{
    int rt;

    printf("\nset switch1 OFF:\n");
    if((rt = set_switch(fd,UCMD_SET_SW,S_LINE1,OFF)) < 0)
    {
        printf("OFF Line1 failed!\n");
        return -1;
    }

    printf("\nset switch2 OFF:\n");
     if((rt = set_switch(fd,UCMD_SET_SW,S_LINE2,OFF)) < 0)
    {
        printf("OFF Line2 failed!\n");
        return -1;
    }

     printf("\nset switch1/2(LINE1/2) OFF Success\n");
     return 0;
}


int set_single_switch(int fd,unsigned char switch_key,int value)
{
    int rt;


    if(value == 1)
    {
        printf("\nset switch%d ON:\n",switch_key);
        rt = set_switch(fd,UCMD_SET_SW,switch_key,ON);
    }
    else if(value == 0)
    {
        printf("\nset switch%d OFF:\n",switch_key);
        rt = set_switch(fd,UCMD_SET_SW,switch_key,OFF);
    }

    return rt;
}


void usage()
{
    printf("usage function!\n");
    printf("Usage:\nswitch_controller [-m/--line-mode ADSL|VDSL] [-B/--Bonding 1|0] [-e/--Ethernet 1|0] [-l/--line-index <switch_index>] [-u/--usb1 1|0] [-w/--usb2 1|0] [-p/--dut-power 1|0] [-a/--ac-power1 1|0] [-b/--ac-power2 1|0] [-c/--ac-power3 1|0] [-d/--ac-power4 1|0] [-D/--delay-time delay_time] [-s/--serial-dev serial_dev] [-n/--off-all] [-v/--verbose]\n");
    printf("       -m/--line-mode:  ADSL or VDSL for WAN connection\n");
    printf("       -B/--Bonding:    1 or 0, 1 means Bonding enable and 0 is disable for WAN connection\n");
    printf("       -e/--Ethernet:   1 or 0, 1 means Ethernet connection ON\n");
    printf("       -l/--line-index: switch index to operate, from 1 to 12, switch 1/2 is for WAN connection\n");
    printf("       -u/--usb1:       1 or 0, set usb1 ON or OFF\n");
    printf("       -w/--usb2:       1 or 0, set usb2 ON or OFF\n");
    printf("       -p/--dut-power:  1 or 0, set dut power ON or OFF\n");
    printf("       -a/--ac-power1:  1 or 0, set AC power1 ON or OFF\n");
    printf("       -b/--ac-power2:  1 or 0, set AC power2 ON or OFF\n");
    printf("       -c/--ac-power3:  1 or 0, set AC power3 ON or OFF\n");
    printf("       -d/--ac-power4:  1 or 0, set AC power4 ON or OFF\n");
    printf("       -D/--delay-time: set a duration,if delay_time > 0,then line1 or line2(specify by line-index) will OFF first, and ON after the duration; the same action for other switches(specify by line-index)\n");
    printf("       -s/--serial-dev: serial_dev(ex. /dev/ttyS0) responding to switch controller in use\n");
    printf("       -n/--off-all:    off all line\n");
    printf("       -v/--verbose:    verbose\n");   
    exit(0);
}


int main(int argc, char **argv)
{
    int fd;
    int rt = RT_FALSE;
    int next_option;
    int option_index = 0;
    char *line_mode;
    unsigned char ch_time = 0,ch_switch = 0;
    int off_all = 0;
    int Bonding,eth_con,line_index,usb1,usb2,dut_power,ac_power1,ac_power2,ac_power3,ac_power4,delay_time = 0;
    int flag_dsl_setting = 0,
        flag_eth_setting = 0,
        flag_usb1_setting = 0,
        flag_usb2_setting = 0,
        flag_dut_setting = 0,
        flag_ac1_setting = 0,
        flag_ac2_setting = 0,
        flag_ac3_setting = 0,
        flag_ac4_setting = 0;
    char *serial_dev = DEVICE;


    printf("%s version %s (%s)\n\n",argv[0],REV,TIME);
            
    static const char *shortOptions = "hHm:B:e:l:u:w:p:a:b:c:d:D:s:nv";
    static struct option longOptions[] =
    {
        {"help", no_argument , NULL, 'H'},
        {"line-mode", required_argument, NULL, 'm'},//--line-mode=ADSL/VDSL
        {"Bonding", required_argument, NULL, 'B'},//--Bonding=1/0
        {"Ethernet", required_argument , NULL, 'e'},
        {"line-index", required_argument, NULL, 'l'},//--line-index=1/2
        {"usb1", required_argument, NULL, 'u'},
        {"usb2", required_argument, NULL, 'w'},
        {"dut-power", required_argument , NULL, 'p'},
        {"ac-power1", required_argument, NULL, 'a'},
        {"ac-power2", required_argument, NULL, 'b'},
        {"ac-power3", required_argument, NULL, 'c'},
        {"ac-power4", required_argument, NULL, 'd'},
        {"delay-time", required_argument, NULL, 'D'},
        {"serial-dev", required_argument, NULL, 's'},
        {"off-all", no_argument , NULL, 'n'},//off all line
        {"verbose", no_argument , NULL, 'v'},//verbose
        {NULL}
    };
    
    opterr = 0;
    
    while ((next_option = getopt_long(argc, argv, shortOptions, longOptions, &option_index)) != EOF)
    {
        switch (next_option)
        {
            case 'm':
                flag_dsl_setting = 1;
                line_mode = optarg;
                break;

            case 'B':
                Bonding = atoi(optarg);
                break;

            case 'e':
                flag_eth_setting = 1;
                eth_con = atoi(optarg);
                break;

            case 'l':
                line_index = atoi(optarg);
                break;

            case 'u':
                flag_usb1_setting = 1;
                usb1 = atoi(optarg);
                break;

            case 'w':
                flag_usb2_setting = 1;
                usb2 = atoi(optarg);
                break;

            case 'p':
                flag_dut_setting = 1;
                dut_power = atoi(optarg);
                break;

            case 'a':
                flag_ac1_setting = 1;
                ac_power1 = atoi(optarg);
                break;

            case 'b':
                flag_ac2_setting = 1;
                ac_power2 = atoi(optarg);
                break;

            case 'c':
                flag_ac3_setting = 1;
                ac_power3 = atoi(optarg);
                break;

            case 'd':
                flag_ac4_setting = 1;
                ac_power4 = atoi(optarg);
                break;

            case 'n':
                off_all = 1;
                break;

            case 'D':
                delay_time = atoi(optarg);
                break;

            case 's':
                serial_dev = optarg;
                break;

            case 'v':
                verbose = 1;
                break;

            case 'h':
            case 'H':
                usage();
            case '?':
            default:
                usage();
                break;
        }
    }

    if (argc < 2 || strcmp(argv[1],"?") == 0)
        usage();

    if (verbose == 1)
        printf("Using serial_dev=%s\n", serial_dev);
    /*open service port*/
    if((fd=open_port(fd, serial_dev)) < 0)
    {
        perror("open_port error");
        return -1;
    }
    
    if(set_opt(fd,BAUDRATE,8,'N',1) < 0)
    {
        perror("set_opt error");
        return -1;
    }
    
    printf("fd=%d\n",fd);


    /*get current switch state*/
    rc_body cursta;
    printf("\nget current switch board state\n");
    if((rt = read_switch(fd,UCMD_GET_ALL,'4','4',&cursta)) < 0)
    {
        printf("get current switch state failed!\n");
        return -1;
    }

    if(off_all == 1)
    {
       if(off_all_line(fd) < 0)
        {
            printf("off all the lines failed!\n");
            return -1;
        }
    }
    
    /*DSL setting*/
    if(flag_dsl_setting == 1)
    {
        if(off_all_line(fd) < 0)
        {
            printf("off all line failed!\n");
            return -1;
        }

        if(Bonding == 1)
        {
            if(strcmp(line_mode,"ADSL") == 0)
            {
                set_single_switch(fd,S_DSL,OFF);
            }
            else if(strcmp(line_mode,"VDSL") == 0)
            {
                set_single_switch(fd,S_DSL,ON);
            }
            set_single_switch(fd,S_BONDING,ON);

            if(off_all == 0)
            {
                set_single_switch(fd,S_LINE1,ON);
                set_single_switch(fd,S_LINE2,ON);
            }
        }
        else if(Bonding == 0)
        {
            if(strcmp(line_mode,"ADSL") == 0)
            {
                set_single_switch(fd,S_DSL,OFF);
            }
            else if(strcmp(line_mode,"VDSL") == 0)
            {
                set_single_switch(fd,S_DSL,ON);
            }
            set_single_switch(fd,S_BONDING,OFF);

            if(off_all == 0)
            {
                if(line_index == 1)
                    set_single_switch(fd,S_LINE1,ON);
                else if(line_index == 2)
                    set_single_switch(fd,S_LINE2,ON);
            }
        }
    }

    if(flag_eth_setting == 1)
    {
        set_single_switch(fd,S_ETHERNET,eth_con);
    }
    
    if(flag_usb1_setting == 1)
    {
        set_single_switch(fd,S_USB1,usb1);
    }

    if(flag_usb2_setting == 1)
    {
        set_single_switch(fd,S_USB2,usb2);
    }

    if(flag_dut_setting == 1)
    {
        set_single_switch(fd,S_DUT_POWER,dut_power);
    }

    if(flag_ac1_setting == 1)
    {
        set_single_switch(fd,S_AC_POWER1,ac_power1);
    }

    if(flag_ac2_setting == 1)
    {
        set_single_switch(fd,S_AC_POWER2,ac_power2);
    }

    if(flag_ac3_setting == 1)
    {
        set_single_switch(fd,S_AC_POWER3,ac_power3);
    }

    if(flag_ac4_setting == 1)
    {
        set_single_switch(fd,S_AC_POWER4,ac_power4);
    }


    if(delay_time > 0)
    {
        if(delay_time > 255)
        {
            printf("delay time is out of range!\n");
        }
        else
        {
            printf("before convert ch_time=0x%x, delay_time=%d\n", ch_time, delay_time);
            ch_time &= 0;
            ch_switch &= 0;
            ch_time |= delay_time;
            if(line_index > 0)
            {
                ch_switch |= line_index;
                printf("set switch%d(0x%x) with delay_time=%d(0x%x):\n",
                        line_index, ch_switch, delay_time, ch_time);
                set_switch(fd,UCMD_SET_FLSH,ch_switch,ch_time);
            }
//            receive_from_mcu(fd,&cursta);
        }
    }
    close(fd);
    return 0;

}//end main();

