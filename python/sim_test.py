import sys
import csv
import codecs
import os
from design.example import Example
from pprint import pprint
from sklearn.feature_extraction import DictVectorizer
from sklearn.feature_extraction.text import TfidfTransformer

from sklearn.metrics.pairwise import cosine_similarity


def parse_conll(text):
    return [[line.split('\t') for line in sent.split('\n')]
            for sent in text.split('\n\n')[:-1]][1:]

def main():
    storting_csv = sys.argv[1]
    annotations_path = sys.argv[2]

    csv_reader = csv.DictReader(open(storting_csv))

    examples = []

    v = DictVectorizer(sparse=False)


    print 'Reading speeches and extracting features...'
    for speech in csv_reader:
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

        example.add_feature('#gender:%s' % (metadata['rep_gender']))

        sentlengths = []
        for sentence in parse_conll(annotations):
            sentlengths.append(float(len(sentence)))
            for token in sentence:
                #example.add_feature('#token:' + token[1])
                example.add_feature('#lemma-pos:%s-%s' % (token[2], token[3]))

        average_sent_length = sum(sentlengths) / len(sentlengths)
        example.add_feature('#avg-s-length:%s' % (average_sent_length))
        examples.append(example)

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
        if e.metadata['date'] not in parties[e.label]:
            year = int(e.metadata['date'].split('-')[0])
            parties[e.label][year] = []
        parties[e.label][year].append(x)
    print 'Done!'

    # for p in parties:
    #     print sorted(parties[p].keys())

    results = {}

    print 'Computing similarities:'
    for p in parties:
        results[p] = {}
        for y in parties[p]:
            results[p][y] = []
            for i, x in enumerate(parties[p][y]):
                print 'foo'
                for j, y in enumerate(parties[p][y]):
                    print 'bar'
                    if j != i:
                        'baz'
                        score = cosine_similarity(x, y)[0][0]
                        print score
                        results[p][y].append(score)
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