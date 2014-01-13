//------------------------------------------------------
// Name: getversion.c
//  Author Joe Nguyen
// Description :
//   Utility to read the Image version of BHR2/BHR1 
//-----------------------------------------------------

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#define RU_START_SECTION "start section"
typedef struct {
  unsigned long image_size;
  unsigned char headers_sig[16];
  unsigned char headers_n_data_sig[16];
} rmt_upd_header_t;
typedef struct {
  unsigned long image_size;
} q1000_t;

typedef struct {
  unsigned char broad[20];
  unsigned char version[50];
} q1000_header_t;


char buff[1024];
char *version="version 2.0";
char *usage="Error: Usage:getversion -f <image filename>\n";
int main (int argc, char **argv) {
  char *p;
  int len;
  char build[80];
  int aflag = 0;
  char *filename = NULL;
  int index;
  int c,temp;
  FILE *fdesc;
  char *res;
  unsigned char reg_hw[20]="Q1000";
  unsigned char broad[20]="Broadcom Corporatio";
  q1000_header_t *ptr;
  int found = 0;
  opterr = 0;
     
  while ((c = getopt (argc, argv, "af:")) != -1 ) 
    {
      switch (c)
	{
	case 'a':
	  aflag = 1;
	  break;
	case 'f':
	  filename = optarg;
	  break;
	case '?':
	  if (optopt == 'f')
	    fprintf (stderr,usage, optopt);
	  else if (isprint (optopt))
	    fprintf (stderr, "Unknown option `-%c'.\n", optopt);
	  else 
	    fprintf (stderr,"Unknown option character `\\x%x'.\n",optopt);
	  exit (1);
	  break;
	default:
	abort ();
	}
    }
  c = 0;
  printf ("---------------------------------------------\n");
  printf ("Utility to Read Actiontec Image Header %s\n",version);
  printf ("---------------------------------------------\n");
  for (index = optind; index < argc; index++) {
    printf ("Non-option argument %s\n%s", argv[index],usage);
    c = 1;
  }
  if  (c == 1 ) exit (1);
  printf ("Image filename= %s\n",filename);
  if ((fdesc = fopen(filename, "r")) == NULL)
    {
 	fprintf(stderr, "Can't open file %s: %s", buff, strerror(errno));
 	exit (1) ;
    }
  if (fseek(fdesc, sizeof(rmt_upd_header_t), SEEK_SET))
    {
      perror("Can't offset pointer file");
      exit (1) ;
    }

  while ((res = fgets(buff, sizeof(buff), fdesc)) && buff[0])
    {
      if (!strcmp(buff, RU_START_SECTION "\n"))
	printf("\nproduct header:\n");
      printf("%s", buff);
      found =1;
    }
  if (!res)
    {
      printf("Can't read from file");
      exit(1);
    }
  if ( found == 1 ) exit (0);
  printf("Start to test Q1000 header \n");
  if (fseek(fdesc, sizeof(q1000_t), SEEK_SET))
    {
      perror("Can't offset pointer file");
      exit (1) ;
    }
  found = 0;    
  res = fgets(buff, sizeof(buff), fdesc);
  if (!res)
    {
      printf("Can't read from file");
      exit(1);
    }
  ptr = (q1000_header_t *) buff;
  if(strcmp(ptr->broad,broad) == 0) {
    //    printf("identical words\n");
  } else
    {
      printf("%s comes before %s", (strcmp(ptr->broad, broad) > 0) ? broad : ptr->broad, (strcmp(ptr->broad, broad) < 0) ? broad : ptr->broad);
      strcpy(reg_hw,ptr->broad);
    }
  p = strchr(filename, '-');
  //  printf("1:%s\n",p+1);
  len = strcspn(p+1, "-");
  //printf(" \n---:%d -- sizeof build %d\n", len, sizeof(build));
  if ( len > sizeof (build ) ) {
    len =sizeof (build);
  }
  strncpy(build,p+1,len);
  //  p=(char *) &newmsg[len+1];
  //*(int *)p= (int)"\0";
  build[len]='\0';


  printf ("reg_hw: %s\ndist: %s\next_ver: %s\nversion: %s\n", reg_hw, reg_hw,build,ptr->version );
  //  printf ("\ncompany: %s\nversion: %s\n", ptr->broad, ptr->version );
  exit (0);
}





