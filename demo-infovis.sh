#!/bin/bash

DEMO_PATH=demo-infovis
DOWNLOAD_PATH=$DEMO_PATH/download
CORPUS_PATH=$DEMO_PATH/corpus
MALLET_PATH=$DEMO_PATH/model-mallet
MALLET_APP=infovis
GENSIM_PATH=$DEMO_PATH/model-gensim
GENSIM_APP=infovis_gensim

function __create_folder__ {
	FOLDER=$1
	TAB=$2
	if [ ! -d $FOLDER ]
	then
		echo "${TAB}Creating folder: $FOLDER"
		mkdir $FOLDER
	fi
}

function __fetch_data__ {
	echo "# Setting up the infovis dataset..."
	__create_folder__ $DEMO_PATH "    "
	
	if [ ! -e "$DEMO_PATH/README" ]
	then
		echo "After a model is imported into a Termite server, you can technically delete all content in this folder without affecting the server. However you may wish to retain your model for other analysis purposes." > $DEMO_PATH/README
	fi

	if [ ! -d "$DOWNLOAD_PATH" ]
	then
		__create_folder__ $DOWNLOAD_PATH "    "
		echo "    Downloading the infovis dataset..."
		curl --insecure --location http://homes.cs.washington.edu/~jcchuang/misc/files/infovis-papers.zip > $DOWNLOAD_PATH/infovis-papers.zip
	else
		echo "    Already downloaded: $DOWNLOAD_PATH"
	fi
	
	if [ ! -d "$CORPUS_PATH" ]
	then
		__create_folder__ $CORPUS_PATH "    "
		echo "    Uncompressing the infovis dataset..."
		unzip $DOWNLOAD_PATH/infovis-papers.zip -d $CORPUS_PATH &&\
		    mv $CORPUS_PATH/infovis-papers/* $CORPUS_PATH &&\
		    rmdir $CORPUS_PATH/infovis-papers
	else
		echo "    Already available: $CORPUS_PATH"
	fi

	echo
}

function __train_mallet__ {
	echo "# Training a MALLET LDA topic model..."
	echo
	echo "bin/train_mallet.sh $CORPUS_PATH/infovis-papers.txt $MALLET_PATH"
	echo
	bin/train_mallet.sh $CORPUS_PATH/infovis-papers.txt $MALLET_PATH
	echo
}

function __import_mallet__ {
	echo "# Importing a MALLET LDA topic model..."
	echo
	echo "bin/ImportMallet.py $MALLET_PATH $MALLET_APP"
	echo
	bin/ImportMallet.py $MALLET_PATH $MALLET_APP
	echo
	echo "bin/ImportCorpus.py $MALLET_APP $CORPUS_PATH/infovis-papers-meta.txt"
	echo
	bin/ImportCorpus.py $MALLET_APP $CORPUS_PATH/infovis-papers-meta.txt
	echo
}

function __train_gensim__ {
	echo "# Training a gensim LDA topic model..."
	echo
	echo "bin/TrainGensim.py $CORPUS_PATH/infovis-papers.txt $GENSIM_PATH"
	echo
	bin/TrainGensim.py $CORPUS_PATH/infovis-papers.txt $GENSIM_PATH
	echo
}
function __import_gensim__ {
	echo "# Importing a gensim LDA topic model..."
	echo
	echo "bin/ImportGensim.py $GENSIM_PATH $GENSIM_APP"
	echo
	bin/ImportGensim.py $GENSIM_PATH $GENSIM_APP
	echo
}

if [ $# -gt 0 ]
then
	MODEL=$1
else
	MODEL=mallet
fi
if [ "$MODEL" == "mallet" ] || [ "$MODEL" == "all" ]
then
	bin/setup.sh
	__fetch_data__
	__train_mallet__
	__import_mallet__
elif [ "$MODEL" == "gensim" ] || [ "$MODEL" == "all" ]
then
	bin/setup_web2py.sh
	bin/setup_gensim.sh
	__fetch_data__
	__train_gensim__
	__import_gensim__
fi
bin/start_server.sh
