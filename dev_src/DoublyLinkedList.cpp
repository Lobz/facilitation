#include<stdlib.h>

template <class Content>
class DoublyLinkedList {

	private:
	*DLLnode head = NULL;
	int lenght = 0;

	public:
	void lenght();
	DLLnode push(Content content);
	Content pop();
	Content remove(DLLnode *rem);
	DLLnode* head()

}

class DLLnode {
	friend class DoublyLinkedList;

	private:
	Content content;
	DLLnode *next, *previous;

	public:
	DLLnode(Content content, DLLnode *next, DLLnode *previous): content(content), next(next), previous(previous);

}

DLLnode DoublyLinkedList::push(Content content){
	head = new DLLnode(content, head, NULL);

	lenght++;
	return head;
}

DLLnode* DoublyLinkedList::head(){
	return head;
}

Content DoublyLinkedList::pop(){
	return remove(head);
}

Content DoublyLinkedList::remove(DLLnode *rem){
	Content c;
	lenght --;
	if(rem.next != NULL) rem.next.next = rem.previous;
	if(rem.previous != NULL) rem.previous.previous = rem.next;

	c = rem.content;
	delete(rem);
	return c;
}

