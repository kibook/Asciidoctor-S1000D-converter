.PHONY: all clean

SOURCE=DMC-S1000DBIKE-AAA-D00-00-00-00AA-041A-A_011-00_EN-US.adoc
OUTPUT=DMC-S1000DBIKE-AAA-D00-00-00-00AA-041A-A_011-00_EN-US.XML

all: $(OUTPUT)

$(OUTPUT): $(SOURCE) s1000d.rb
	asciidoctor --trace -b s1000d -r ./s1000d.rb -o $@ $<

clean:
	rm -f $(OUTPUT)
