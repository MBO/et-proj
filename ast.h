#ifndef AST_H
#define AST_H

#include <vector>
#include <iostream>

class Node
{
private:
    std::string name;
public:
    void shift(int offset)
    {
        std::cout.width(offset*4);
        std::cout << "";
    }
    virtual void print(int offset)
    {
        shift(offset);
        std::cout << name << "\n";
    }
    Node(std::string n = "Node") : name(n) {}
    virtual Node* add(Node*) { return this; }
    virtual ~Node() {}
};
class EmptyNode : public Node
{
public:
    EmptyNode() {}
    void print(int offset) {}
};
class PatternNode : public Node
{
private:
    std::vector<Node*> branches;
public:
    PatternNode(Node* node)
    {
        add(node);
    }
    ~PatternNode()
    {
        for (std::vector<Node*>::iterator i = branches.begin();
                i != branches.end(); i++)
        {
            delete *i;
        }
    }

    Node* add(Node* node)
    {
        branches.push_back(node);
        return this;
    }

    void print(int offset)
    {
        std::vector<Node*>::iterator i;

        if (branches.size() > 1) {
            shift(offset);
            std::cout << "Jedno z podwyrazen\n";
            i = branches.begin();
            Node *n = *i;
            n->print(offset+1);
            i++;
            while(i != branches.end())
            {
                Node *n = *i;
                shift(offset);
                std::cout << "...lub\n";
                n->print(offset+1);
                i++;
            }
        }
        else {
            branches[0]->print(offset);
        }
    }
};

class BranchNode : public Node
{
private:
    std::vector<Node*> pieces;
public:
    BranchNode(Node* node)
    {
        add(node);
    }
    ~BranchNode()
    {
        for (std::vector<Node*>::iterator i = pieces.begin();
                i != pieces.end(); i++)
        {
            delete *i;
        }
    }

    Node* add(Node* node)
    {
        pieces.push_back(node);
        return this;
    }
    void print(int offset)
    {
        std::vector<Node*>::iterator i;

        i = pieces.begin();
        while(i != pieces.end())
        {
            Node *n = *i;
            n->print(offset);
            i++;
        }
    }
};
class PieceNode : public Node
{
private:
    int min;
    int max;
    Node* n;
public:
    PieceNode(Node *node, int min, int max) : min(min), max(max)
    {
        n = node;
    }
    ~PieceNode()
    {
        delete n;
    }

    void print(int offset)
    {
        if ((min == -1) && (max == -1)) {
            n->print(offset);
        }
        else {
            shift(offset);
            std::cout << "Poniższe podwyrazenie ";
            if (min == max) {
                std::cout << "dokladnie " << min << " raz(y)\n";
            }
            else if ((min == 0) && (max == -1)) {
                std::cout << "dowolna ilosc raz(y)\n";
            }
            else if (min == 0) {
                std::cout << "co najwyzej " << max << " raz(y)\n";
            }
            else if (max == -1) {
                std::cout << "co najmniej " << min << " raz(y)\n";
            }
            else {
                std::cout << "od " << min << " do " << max << " raz(y)\n";
            }
            n->print(offset+1);
        }
    }
};
class SubpatternNode : public Node
{
private:
    Node* subpattern;
public:
    SubpatternNode(Node *node)
    {
        subpattern = node;
    }
    ~SubpatternNode()
    {
        delete subpattern;
    }

    void print(int offset)
    {
        shift(offset);
        std::cout << "Podwyrażenie\n";
        subpattern->print(offset+1);
    }
};
class CharacterNode : public Node
{
private:
    int character;
public:
    CharacterNode() {}
    CharacterNode(int ch) : character(ch) {}

    virtual void print(int offset)
    {
        shift(offset);
        std::cout << "znak ";
        printCh();
        std::cout << " (0x" << std::hex << character << ")\n";
    }
    virtual void printCh()
    {
        std::cout << "'";
        std::cout.put((char)character);
        std::cout << "'";
    }
};
class SpecialCharNode : public CharacterNode
{
private:
    int character;
public:
    SpecialCharNode(int ch) : character(ch) {}

    void print(int offset)
    {
        shift(offset);
        std::cout << "znak specjalny ";
        printCh();
        std::cout << " ASCII ";
        switch (character) {
            case 'a':
                std::cout << "bell (BEL, 0x07)";
                break;
            case 'f':
                std::cout << "form feed (FF, 0x0C)";
                break;
            case 'n':
                std::cout << "line feed (LF, 0x0A, Unix newline)";
                break;
            case 'r':
                std::cout << "carrige return (CR, 0x0D)";
                break;
            case 't':
                std::cout << "horizontal tab (HT, 0x09)";
                break;
            case 'v':
                std::cout << "vertical tab (VT, 0x0B)";
                break;
        }
        std::cout << "\n";
    }
    void printCh()
    {
        std::cout << "\\";
        std::cout.put((char)character);
    }
};
class HexCharNode : public CharacterNode
{
private:
    int num;
public:
    HexCharNode(int n) : num(n) {}

    void print(int offset)
    {
        shift(offset);
        std::cout << "znak Unicode o kodzie szesnastkowym ";
        printCh();
        std::cout << "\n";
    }
    void printCh()
    {
        std::cout << "\\0x";
        std::cout.width(4);
        std::cout.fill('0');
        std::cout << std::hex << num;
        std::cout.fill(' ');
    }
};
class OctCharNode : public CharacterNode
{
private:
    int num;
public:
    OctCharNode(int n) : num(n) {}

    void print(int offset)
    {
        shift(offset);
        std::cout << "znak ASCII/Latin1 o kodzie osemkowym ";
        printCh();
        std::cout << "\n";
    }
    void printCh()
    {
        std::cout << "\\0";
        std::cout.width(3);
        std::cout.fill('0');
        std::cout << std::oct << num << "\n";
        std::cout.fill(' ');
    }
};
class BackrefNode : public Node
{
private:
    int num;
public:
    BackrefNode(int n) : num(n) {}

    void print(int offset)
    {
        shift(offset);
        std::cout << "odwolanie do " << num << "-go podwyrazenia w nawiasach\n";
    }
};
class PredClassNode : public Node
{
private:
    int character;
public:
    PredClassNode(int ch) : character(ch) {}

    void print(int offset)
    {
        shift(offset);
        switch (character) {
            case 'd':
                std::cout << "znak reprezentujący cyfre [0-9]";
                break;
            case 'D':
                std::cout << "dowolny znak nie będący cyfrą";
                break;
            case 's':
                std::cout << "znak reprezentujacy bialy znak (spacja, tabulator)";
                break;
            case 'S':
                std::cout << "dowolny znak nie bedocy bialym znakiem (nie spacja lub tabulator)";
                break;
            case 'w':
                std::cout << "znak alfanumeryczny lub '_' [a-zA-Z_]";
                break;
            case 'W':
                std::cout << "dowolny znak nie bedacy znakiem alfanumerycznym czy tez '_'";
                break;
        }
        std::cout << "\n";
    }
};
class BracketNode : public Node
{
private:
    bool negated;
    Node *n;
public:
    BracketNode(bool neg, Node *node)
    {
        negated = neg;
        n = node;
    }
    ~BracketNode()
    {
        delete n;
    }

    void print(int offset)
    {
        shift(offset);
        if (negated) {
            std::cout << "Dowolny znak nie nalezacy do ponizszych\n";
        }
        else {
            std::cout << "Jeden z ponizszych znakow\n";
        }
        n->print(offset+1);
    }
};
class RangeNode : public Node
{
private:
    CharacterNode *low;
    CharacterNode *high;
public:
    RangeNode(CharacterNode *ch1, CharacterNode *ch2) : low(ch1), high(ch2) {}
    ~RangeNode()
    {
        delete low;
        delete high;
    }

    void print(int offset)
    {
        shift(offset);
        std::cout << "dowolny znak z zakresu ";
        low->printCh();
        std::cout << " do ";
        high->printCh();
        std::cout << "\n";
    }
};
class BracketListNode : public Node
{
private:
    Node *n1;
    Node *n2;
    Node *n3;
public:
    BracketListNode(Node *n1, Node *n2, Node *n3) : n1(n1), n2(n2), n3(n3)
    {
    }
    ~BracketListNode()
    {
        delete n1;
        delete n2;
        delete n3;
    }

    void print(int offset)
    {
        n1->print(offset);
        n2->print(offset);
        n3->print(offset);
    }
};
class FollowListNode : public Node
{
private:
    std::vector<Node*> expressions;
public:
    FollowListNode(Node *n)
    {
        add(n);
    }
    ~FollowListNode()
    {
        for (std::vector<Node*>::iterator i = expressions.begin();
                i != expressions.end(); i++)
        {
            delete *i;
        }
    }

    Node* add(Node *n)
    {
        expressions.push_back(n);
        return this;
    }
    void print(int offset)
    {
        for (std::vector<Node*>::iterator i = expressions.begin();
                i != expressions.end(); i++)
        {
            Node *n = *i;
            n->print(offset);
        }
    }
};

#endif /* AST_H */
