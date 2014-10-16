//------------------------------------------------------
// Name: busyscreen.c
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


char buff[1024];
char *version="version 1.0";
char *usage="Error: Usage:busyscreen -m <message >  \n";
int main (int argc, char **argv) {
  int aflag = 0;
  char *message = "busyscreen";
  int index;
  int c;
  FILE *fdesc;
  char *res;
  opterr = 0;
     
  while ((c = getopt (argc, argv, "m:")) != -1 ) 
    {
      switch (c)
	{
	case 'm':
	  message = optarg;
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
  printf ("Print Busy screen with message  %s\n",version);
  printf ("---------------------------------------------\n");
  for (index = optind; index < argc; index++) {
    printf ("Non-option argument %s\n%s", argv[index],usage);
    c = 1;
  }
  if  (c == 1 ) exit (1);
  printf ("Message to be printed out= %s",message);
  index = 1;
  while ( index  ) {
    printf ( "%s ",message);
  }

exit (0);
}
