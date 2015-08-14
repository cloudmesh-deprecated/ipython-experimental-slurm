clean:
	rm *~
	rm munge.key

pdf:
	pandoc README.md -o README.pdf
doc:
	notedown README.md >> doc.ipynb

notebook: doc
	ipython notebook doc.ipynb
