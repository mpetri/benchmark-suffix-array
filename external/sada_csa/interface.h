#pragma once
/* General interface for using the compressed index libraries */

#ifndef UCHAR
#define UCHAR unsigned char
#endif
#ifndef UINT
#define UINT  unsigned int
#endif
#ifndef ULONG
#define ULONG unsigned long
#endif

/* Error management */

        /* Returns a string describing the error associated with error number
          e. The string must not be freed, and it will be overwritten with
          subsequent calls. */

char *error_index (int e);

/* Building the index */

        /* Creates index from text[0..length-1]. Note that the index is an 
          opaque data type. Any build option must be passed in string 
          build_options, whose syntax depends on the index. The index must 
          always work with some default parameters if build_options is NULL. 
          The returned index is ready to be queried. */

int build_index (UCHAR *text, ULONG length, char *build_options, void **index);

        /*  Saves index on disk by using single or multiple files, having 
          proper extensions. */

int save_index (void *index, char *filename);

        /*  Loads index from one or more file(s) named filename, possibly 
          adding the proper extensions. */

int load_index (char *filename, void **index);

        /* Frees the memory occupied by index. */

int free_index (void *index);

        /* Gives the memory occupied by index in bytes. */

int index_size(void *index, ULONG *size);

/* Querying the index */

        /* Writes in numocc the number of occurrences of the substring 
          pattern[0..length-1] found in the text indexed by index. */

int count (void *index, UCHAR *pattern, ULONG length, ULONG *numocc);

        /* Writes in numocc the number of occurrences of the substring 
          pattern[0..length-1] in the text indexed by index. It also allocates
          occ (which must be freed by the caller) and writes the locations of 
          the numocc occurrences in occ, in arbitrary order.  */

int locate (void *index, UCHAR *pattern, ULONG length, ULONG **occ, 
        ULONG *numocc);

        /* Gives the length of the text indexed */

int get_length(void *index, ULONG *length);

/* Accessing the indexed text  */

        /*  Allocates snippet (which must be freed by the caller) and writes 
          the substring text[from..to] into it. Returns in snippet_length the 
          length of the text snippet actually extracted (that could be less 
          than to-from+1 if to is larger than the text size). */

int extract (void *index, ULONG from, ULONG to, UCHAR **snippet, 
        ULONG *snippet_length);

        /* Displays the text (snippet) surrounding any occurrence of the 
          substring pattern[0..length-1] within the text indexed by index. 
          The snippet must include numc characters before and after the 
          pattern occurrence, totalizing length+2*numc characters, or less if 
          the text boundaries are reached. Writes in numocc the number of 
          occurrences, and allocates the arrays snippet_text and 
          snippet_lengths (which must be freed by the caller). The first is a 
          character array of numocc*(length+2*numc) characters, with a new 
          snippet starting at every multiple of length+2*numc. The second 
          gives the real length of each of the numocc snippets. */

int display (void *index, UCHAR *pattern, ULONG length, ULONG numc, 
        ULONG *numocc, UCHAR **snippet_text, ULONG **snippet_lengths);

        /*  Obtains the length of the text indexed by index. */

int length (void *index, ULONG *length);

