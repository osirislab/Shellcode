%define htonq(x) (\
    (((x) & 0x00000000000000ff) << 56) | \
    (((x) & 0x000000000000ff00) << 40) | \
    (((x) & 0x0000000000ff0000) << 24) | \
    (((x) & 0x00000000ff000000) <<  8) | \
    (((x) & 0x000000ff00000000) >>  8) | \
    (((x) & 0x0000ff0000000000) >> 24) | \
    (((x) & 0x00ff000000000000) >> 40) | \
    (((x) & 0xff00000000000000) >> 56))

%define htonl(x) (\
    (((x) & 0x000000ff) << 24) | \
    (((x) & 0x0000ff00) <<  8) | \
    (((x) & 0x00ff0000) >>  8) | \
    (((x) & 0xff000000) >> 24))

%define htons(x) ((((x) & 0xff00) >> 8) | (((x) & 0x00ff) << 8))

%define ip(a,b,c,d) htonl(a << 24 | b << 16 | c << 8 | d) ; ip(127,0,0,1)
	
%define htonx(x)            \
	%if    __BITS__==16 \
		htons(x)    \
	%elif  __BITS__==32 \
		htonl(x)    \
	%elif  __BITS__==64 \
		htonq(x)    \
	%elif               \
		%error "__BITS__ is not 16, 32 or 64" \
	%endif

%macro str_null_check 1
	%assign word_length __BITS__/8
	%strlen len_arg %1
	%if len_arg % word_length!=0
		%fatal "Make string a multiple of the word length"
	%endif
%endmacro

%macro str_null_check 2
	%assign word_length %2/8
	%strlen len_arg %1
	%if len_arg % word_length!=0
		%fatal "Make string a multiple of the word length"
	%endif
%endmacro
	
	;; The PUSH_STRING macros don't null terminate the string
	;; arguments must be known at assemble time

	
%macro PUSH_STRING 2 		;string, bitcount
	str_null_check %1 %2
	%assign word_length %2/8
	%strlen string_length %1
	%assign num_pushes string_length/word_length
	%assign index string_length
	%rep num_pushes
		%substr slice %1 index-word_length+1,word_length
		%assign index index-word_length
		push slice
		%warning push slice
	%endrep
%endmacro 

%macro PUSH_STRING 1 		;string
	str_null_check %1
	%assign word_length __BITS__/8
	%strlen string_length %1
	%assign num_pushes string_length/word_length
	%assign index string_length
	%rep num_pushes
		%substr slice %1 index-word_length+1,word_length
		%assign index index-word_length
		push slice
		%warning push slice
	%endrep
%endmacro 


