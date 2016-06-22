import sys
import csv
import codecs
import os
from tqdm import tqdm
from design.example import Example
from pprint import pprint
from sklearn.feature_extraction import DictVectorizer, FeatureHasher
from sklearn.feature_extraction.text import TfidfTransformer

from sklearn.metrics.pairwise import cosine_similarity

def parse_conll(text):
    return [[line.split('\t') for line in sent.split('\n')]
            for sent in text.split('\n\n')[:-1]][1:]

def main():
    storting_csv = sys.argv[1]
    annotations_path = sys.argv[2]

    loc = os.path.dirname(os.path.abspath(__file__))
    stopwords = [w for w
                 in codecs.open(os.path.join(loc, 'stop.txt'),
                                'r', 'utf8').read().split()
                 if not w.startswith('|')]

    csv_reader = csv.DictReader(open(storting_csv))

    examples = []

    #v = DictVectorizer(sparse=False)
    v = FeatureHasher()

    print 'Reading speeches and extracting features...'
    for speech in csv_reader:
        if speech['party_id']:
            sys.stdout.write(speech['id'])
            sys.stdout.write("\b" * len(speech['id']))
            metadata = {}
            for name in csv_reader.fieldnames:
                if name != 'text':
                    metadata[name] = speech[name]

            label = metadata['party_id']
            example = Example(label, metadata=metadata)

            annotations = codecs.open(os.path.join(annotations_path,
                                                    '%s.tsv' % (speech['id'])),
                                                                'r',
                                                                'utf8').read()

            sentlengths = []
            for sentence in parse_conll(annotations):
                sentlengths.append(float(len(sentence)))
                for token in sentence:
                    if token[1] not in stopwords:
                        #example.add_feature('#token:' + token[1])
                        example.add_feature('#lemma-pos:%s-%s' % (token[2], token[3]))

            average_sent_length = sum(sentlengths) / len(sentlengths)
            example.add_feature('#avg-s-length:%s' % (average_sent_length))
            examples.append(example)

    print
    print 'Done!'
    print 'Vectorizing...'
    X = v.fit_transform([e.features for e in examples])
    print 'Done!'
    print 'Tfidf weighting...'
    t = TfidfTransformer()
    X = t.fit_transform(X)
    print 'Done!'

    print 'Binning vectors...'
    parties = {}
    for e, x in zip(examples, X):
        if e.label not in parties:
            parties[e.label] = {}
        year = int(e.metadata['date'].split('-')[0])
        if year not in parties[e.label]:
            parties[e.label][year] = []
        parties[e.label][year].append(x)
    print 'Done!'

    # for p in parties:
    #     print sorted(parties[p].keys())

    results = {}

    for p in tqdm(parties, desc='Computing similarities:'):
        results[p] = {}
        for year in tqdm(parties[p], desc=p):
            results[p][year] = []
            for i, x in enumerate(tqdm(parties[p][year], desc=str(year))):
                for j, y in enumerate(parties[p][year]):
                    if j != i:
                        score = cosine_similarity(x, y)[0][0]
                        results[p][year].append(score)
    print 'Done!'

    print 'Saving results...'
    na_counter = 0
    for p in results:
        if not p:
            out = open('na_%s' % (na_counter) + '.out', 'w')
            na_counter += 1
        else:
            out = open(p + '.out', 'w')
        years = sorted(results[p].keys())
        for y in years:
            try:
                avg = sum(results[p][y]) / len(results[p][y])
            except ZeroDivisionError:
                avg = 0
            out.write("%s\t%s\n" % (y, avg))
        out.close()
    print 'All done!'

    # for i, x in enumerate(X):
    #     for j, y in enumerate(X):
    #         if j != i:
    #             #print cosine_similarity(x.reshape(1, -1), y.reshape(1, -1))[0][0]
    #             print cosine_similarity(x, y)[0][0]

    print 'done'


if __name__ == '__main__':
    main()
