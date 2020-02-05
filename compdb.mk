%.compdb_entry: %.c
    @echo "    {" > $@
    @echo "        \"command\": \"cc  $(CFLAGS) $(CPPFLAGS) -c $<\","   >> $@
    @echo "        \"directory\": \"$(CURDIR)\","               >> $@
    @echo "        \"file\": \"$<\""                    >> $@
    @echo "    },"                              >> $@

COMPDB_ENTRIES = $(addsuffix .compdb_entry, $(basename $(SOURCES)))

compile_commands.json: $(COMPDB_ENTRIES)
    @echo "[" > $@.tmp
    @cat $^ >> $@.tmp
    @sed '$$d' < $@.tmp > $@
    @echo "    }" >> $@
    @echo "]" >> $@
    @rm $@.tmp

clang-tidy: compile_commands.json
    run-clang-tidy.py

cppcheck: compile_commands.json
    cppcheck --enable=all --inconclusive --std=c99 --project=$(CURDIR)/compile_commands.json --template=gcc

