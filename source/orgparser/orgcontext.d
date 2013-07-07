module orgparser.orgcontext;


struct OrgContext {
    TodoWords todoWords;
    Priorities priorities;
}

/**
 * Words currently recognized as todo state.
 */
struct TodoWords {
    string[] words=["TODO", "DONE"];
    /// Offset from which on all words are some kind of "DONE"
    int doneOffset=1;
}

struct Priorities {
    char highest='A';
    char lowest='C';
    char defaultValue='B';
}
