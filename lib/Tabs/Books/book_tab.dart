import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:mft_final_project/Tabs/Books/addbook.dart';
import 'package:mft_final_project/module/books.dart';

class BookTab extends StatefulWidget {
  final List<Books> books;

  BookTab({required this.books});
  @override
  State<BookTab> createState() => _BookTabState();
}

class _BookTabState extends State<BookTab> {
  List<Books> books = [];
  List<Books> filteredBooks = [];
  final booksBox = Hive.box('books');
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    books = widget.books;
    filteredBooks = books;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
            ),
            onChanged: (value) {
              filterBooks(value);
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: AddBookPage(),
                  ),
                );
              },
            ).then((newBook) {
              if (newBook != null && newBook is Books) {
                setState(() {
                  books.add(newBook);
                  filterBooks(searchController.text);
                });
              }
            });
          },
          child: const Text('Add Book', style: TextStyle(fontSize: 20)),
        ),
        SizedBox(
          height: 40,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text('ID',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('Title',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('Genre',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('Published Date',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('Copies Available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('ISBN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('bookpage',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Text('Actions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final book = filteredBooks[index];
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('${book.bookid}')),
                    Expanded(child: Text('${book.title}')),
                    Expanded(
                        child: Text(
                      '${book.genre}',
                    )),
                    Expanded(
                      child: Text(
                          '${DateFormat('yyyy').format(book.publishedDate)}'),
                    ),
                    Expanded(child: Text('${book.copiesAvailable}')),
                    Expanded(child: Text('${book.isbn}')),
                    Expanded(child: Text('${book.bookpage}')),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddBookPage(book: book),
                          ),
                        ).then((updatedBook) {
                          if (updatedBook != null) {
                            setState(() {
                              booksBox.put(updatedBook.bookid, updatedBook);
                              books[index] = updatedBook;
                              filterBooks(searchController.text);
                            });
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          booksBox.delete(book.bookid);
                          books.removeAt(index);
                          filterBooks(searchController.text);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void filterBooks(String query) {
    setState(() {
      filteredBooks = books.where((book) {
        return book.title.toLowerCase().contains(query.toLowerCase()) ||
            book.genre.toLowerCase().contains(query.toLowerCase()) ||
            DateFormat('yyyy').format(book.publishedDate).contains(query) ||
            book.copiesAvailable.toString().contains(query) ||
            book.isbn.toString().contains(query);
      }).toList();
    });
  }

  void _updateBook(Books updatedBook) {
    final index = books.indexWhere((book) => book.bookid == updatedBook.bookid);
    if (index != -1) {
      setState(() {
        books[index] = updatedBook;
        filterBooks(searchController.text);
      });
    } else {
      setState(() {
        books.add(updatedBook);
        filterBooks(searchController.text);
      });
    }
  }
}