#
# Makefile for generate booklist using barcode
# 
# 
# 
# general infomation about barcodes(in Japanese)
#   http://www.asahi-net.or.jp/~ax2s-kmtn/bcodes.html
#
#   ^978 は書籍JANコード(上段)、
#   ^191, ^192 は 書籍JANコード(下段)、
#
#   ^11 は共通雑誌コード(雑誌Tコード)、文字列としては T11 で始まる。
#
#   書籍JANコード(上段)は978とISBNが9桁、最後にcheck digitをもつ。
#   ISBNは 1-23456-789-0 で左から「グループコード」「出版社コード」「書名コード」「check digit」
#   グループコードは、日本で4、英語圏で0,1、
#

BOOK_BARCODE=	books-barcode-raw.txt    # number lists obtained by barcode scanner is supposed
BOOK_NOBARCODE=	books-barcode-none.txt   # number lists input by hand.
BOOK_JANCODE=	books-jancode.txt        # list of books represented in JAN code
BOOK_ISBN13=	books-isbn-13.txt        # list of books represented in ISBN-13
BOOK_ISBN=	books-isbn-10.txt        # list of books represented in ISBN-10
BOOK_NOISBN=	books-isbn-none.txt      # list of books which doesn't have ISBN
BOOK_LIST=	books-list.txt           # generated file for list of books
BOOK_LIST_RD=	books-list.rd            # generated file in rd format for list of books

SEARCH=		./search-by-isbn13.rb
ISBN13to10=	./isbn13to10.rb

SEARCH_DANBOX=./search-by-isbn13-for-danboxlabel.rb

# 
# 
# 
all: gen_isbn13 search

search: 
	for i in `cat  ${BOOK_ISBN13}|xargs echo`; do ${SEARCH} $${i}; done > ${BOOK_LIST}
	for i in `cat  ${BOOK_NOBARCODE}|xargs echo`; do ${SEARCH} $${i}; done >> ${BOOK_LIST}

dbl:
	for i in `cat  ${BOOK_ISBN13}|xargs echo`; do ${SEARCH_DANBOX} $${i}; done > ${BOOK_LIST}-dbl
	for i in `cat  ${BOOK_NOBARCODE}|xargs echo`; do ${SEARCH_DANBOX} $${i}; done >> ${BOOK_LIST}-dbl

rd:
	echo "=begin" > ${BOOK_LIST_RD}
	cat ${BOOK_LIST} | awk -F' @@@@ ' '{print "* ((<\"" $$1 "(" $$2 ")\"|URL:" $$11  ">)), ISBN-13: "  $$7 }'|sort >> ${BOOK_LIST_RD}
	echo "=end" > ${BOOK_LIST_RD}

gen_isbn10: gen_isbn13
	${ISBN13to10} ${BOOK_ISBN13} > ${BOOK_ISBN}; rm -f tmp.$$$$
	cat ${BOOK_NOBARCODE} >> ${BOOK_ISBN}

gen_isbn13: gen_jancode
	cat ${BOOK_JANCODE} | grep ^978 > ${BOOK_ISBN13}

gen_jancode:
	cat ${BOOK_BARCODE} | sort | uniq | grep -v ^192 | grep -v ^191|grep -v ^4901 | grep -v ^11 > ${BOOK_JANCODE}

clean:
	rm -f ${BOOK_JANCODE} ${BOOK_ISBN13} ${BOOK_ISBN}
