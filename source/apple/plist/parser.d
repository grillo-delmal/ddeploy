module apple.plist.parser;
import apple.plist.entry;
import dxml.dom;
import std.exception : enforce;
import std.stdio : writeln;
import std.conv : to;

private {
    void parseNext(R)(ref PListEntry entry, DOMEntity!R entity) {
        switch(entity.name) {
            default:
                throw new Exception("Unknown type "~entity.name);
            case "string":
                parseString(entry, entity);
                return;
            case "real":
                parseReal(entry, entity);
                return;
            case "integer":
                parseInt(entry, entity);
                return;
            case "true":
                entry = new PListEntry(true);
                return;
            case "false":
                entry = new PListEntry(false);
                return;
            case "dict":
                parseDict(entry, entity);
                return;
            case "array":
                parseArray(entry, entity);
                return;
        }
    }

    void parseReal(R)(ref PListEntry parent, DOMEntity!R entity) {
        parent = new PListEntry(entity.children[0].text.to!double);
    }

    void parseInt(R)(ref PListEntry parent, DOMEntity!R entity) {
        parent = new PListEntry(entity.children[0].text.to!long);
    }

    void parseString(R)(ref PListEntry parent, DOMEntity!R entity) {
        parent = new PListEntry(entity.children[0].text);
    }

    void parseArray(R)(ref PListEntry parent, DOMEntity!R entity) {
        parent = PListEntry.createArray();
        foreach(child; entity.children) {
            PListEntry val;
            parseNext(val, child);

            parent ~= val;
        }
    }

    void parseDict(R)(ref PListEntry parent, DOMEntity!R entity) {
        parent = PListEntry.createDict();
        int i = 0;

        while (i < entity.children.length) {
            if (entity.children[i].name == "key") {
                PListEntry val;
                parseNext(val, entity.children[i+1]);
                parent.set(entity.children[i].children[0].text, val);

                i += 2;
                continue;
            }
            i++;
        }
    }
}

/**
    Parses a PList file and returns the root entry.
*/
PListEntry parse(string text) {
    PListEntry ret;
    
    // Parse XML dom and check whether it contains a plist entry.
    auto dom = parseDOM!(simpleXML)(text);
    enforce(dom.children[0].name == "plist", "Not a PList!");

    if (dom.children[0].name == "plist") {
        parseNext(ret, dom.children[0].children[0]);
    }
    return ret;
}