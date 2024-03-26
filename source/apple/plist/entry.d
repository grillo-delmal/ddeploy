module apple.plist.entry;
import std.range;
import std.format;
import std.exception;
import dxml.dom;

/// XML Type tag of a PList
enum PLIST_XMLT = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";

/// Header at the start of plists
enum PLIST_HEADER = "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n";

/// Type of entry in the plist
enum PListEntryType {
    bool_,
    string_,
    array_,
    dict_,
    real_,
    int_
}

class PListEntry {
private:
    PListEntryType t;
    union {
        long int_;
        double real_;
        bool bool_;
        string string_;
        PListEntry[] array_;
        PListEntry[string] dict_;
    }

    this() { }

public:
    this(string text) {
        this.t = PListEntryType.string_;
        this.string_ = text;
    }

    this(long num) {
        this.t = PListEntryType.int_;
        this.int_ = num;
    }

    this(double num) {
        this.t = PListEntryType.real_;
        this.real_ = num;
    }

    this(bool val) {
        this.t = PListEntryType.bool_;
        this.bool_ = val;
    }

    static PListEntry createDict() {
        PListEntry e = new PListEntry;
        e.t = PListEntryType.dict_;
        return e;
    }

    static PListEntry createArray() {
        PListEntry e = new PListEntry;
        e.t = PListEntryType.array_;
        return e;
    }

    /**
        Sets the specified key in the dictionary entry
    */
    void set(T)(string key, T value) {
        enforce(t == PListEntryType.dict_, "Not a dictionary!");
        static if (is(T == PListEntry)) {
            dict_[key] = value;
        } else {
            dict_[key] = new PListEntry(value);
        }
    }

    /**
        Index array
    */
    ref auto opIndex(size_t index) {
        enforce(t == PListEntryType.array_, "Not an array!");
        return array_[index];
    }

    /**
        Assign value at index
    */
    auto opIndexAssign(T)(T value, size_t index) {
        enforce(t == PListEntryType.array_, "Not an array!");
        static if (is(T == PListEntry)) {
            array_[index] = value;
        } else {
            array_[index] = new PListEntry(value);
        }
        return value;
    }

    /**
        Assign value at index
    */
    auto opIndexAssign(T)(T value, string index) {
        enforce(t == PListEntryType.dict_, "Not an array!");
        static if (is(T == PListEntry)) {
            dict_[index] = value;
        } else {
            dict_[index] = new PListEntry(value);
        }
        return value;
    }

    /**
        Append element
    */
    auto opOpAssign(string op = "~", T)(T value) {
        enforce(t == PListEntryType.array_, "Not an array!");
        static if (is(T == PListEntry)) {
            array_ ~= value;
        } else {
            array_ ~= new PListEntry(value);
        }
        
        return value;
    }

    /**
        Gets the count of elements
    */
    size_t length() {
        switch(t) {
            default: return 1;
            case PListEntryType.array_: return array_.length;
            case PListEntryType.dict_: return dict_.length;
        }
    }

    /**
        Writes PList out to appender
    */
    void write(ref Appender!string app, bool isRoot=false, int ident = 0) {
        // Make file header and initial plist tag.
        if (isRoot) {
            app.put(PLIST_XMLT);
            app.put(PLIST_HEADER);
            app.put("<plist version=\"1.0\">\n");
            ident++;
        }

        foreach(i; 0..ident) {
            app.put("\t");
        }

        final switch(t) {
            case PListEntryType.int_:
                app.put("<integer>%s</integer>\n".format(int_));
                break;
            case PListEntryType.real_:
                app.put("<real>%s</real>\n".format(real_));
                break;
            case PListEntryType.bool_:
                app.put(bool_ ? "<true/>\n" : "<false/>\n");
                break;
            case PListEntryType.string_:
                app.put("<string>%s</string>\n".format(string_));
                break;
            case PListEntryType.array_:
                app.put("<array>\n");

                foreach(element; array_) {
                    element.write(app, false, ident+1);
                }

                foreach(i; 0..ident) {
                    app.put("\t");
                }
                app.put("</array>\n");
                break;
            case PListEntryType.dict_:

                app.put(isRoot ? "<dict>\n" : "<dict>\n");
                foreach(key, element; dict_) {
                    foreach(i; 0..ident+1) {
                        app.put("\t");
                    }
                    app.put("<key>%s</key>\n".format(key));
                    element.write(app, false, ident+1);
                }

                app.put(isRoot ? "\t</dict>\n" : "</dict>\n");
                break;
        }

        // End PList tag
        if (isRoot) {
            app.put("</plist>");
        }
    }

    /**
        Write the PList to a file
    */
    void writeToFile(string file) {
        import std.file : write;
        auto app = appender!string;
        this.write(app, true);
        write(file, app.data);
    }
}