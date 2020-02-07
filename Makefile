.PHONY: all clean

SOURCE=DMC-S1000DBIKE-AAA-D00-00-00-00AA-041A-A_011-00_EN-US.adoc
OUTPUT=DMC-S1000DBIKE-AAA-D00-00-00-00AA-041A-A_011-00_EN-US.XML

ASCIIDOCTOR=asciidoctor --trace -b s1000d -r ./s1000d.rb -o -
VALIDATE_SCHEMA=http://www.s1000d.org/S1000D_5-0/xml_schema_flat/descript.xsd
VALIDATE=s1kd-validate -s $(VALIDATE_SCHEMA) -ov

all: $(OUTPUT)

$(OUTPUT): $(SOURCE) s1000d.rb
	$(ASCIIDOCTOR) $< | s1kd-icncatalog | $(VALIDATE) | xml-format -o $@

clean:
	rm -f $(OUTPUT)
