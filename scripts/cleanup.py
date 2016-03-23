#!/usr/bin/python
# -*- coding: utf-8 -*-
import os
import codecs
import re
import sys
from HTMLParser import HTMLParser


RUBBISH = ['script', 'meta']
NAME_PARTY_RE = re.compile(".+\(.+\) \[.+\]", re.UNICODE)
MINISTER_RE = re.compile("Statsr.d .+ \[.+\]", re.UNICODE)

def ensure_dir(d):
    if not os.path.exists(d):
        os.makedirs(d)
        print "[ WRITING ] created directory %s" % (d.encode('utf8'))

def safewrite(d, f, data):
    aw = 'w'
    if os.path.exists(os.path.join(d, "%s.txt" % (f))):
        aw = 'a'
    try:
        with codecs.open(os.path.join(d, "%s.txt" % (f)), aw, 'utf8') as out:
            out.write(data + '\n\n')
        log_str = 'updated' if aw == 'a' else 'created'
        print "[ WRITING ] %s file:" % (log_str), d.encode('utf8'), f + '.txt'
    except IOError as e:
        print "[ WRITING ] Got IOError: %s" % (e)

def parse_stortinget_speaker(s):
    name, party, timestamp = ('', '', '')
    try:
        if re.search(NAME_PARTY_RE, s):
            name = '_'.join(s.split('(')[0].split()).lower().strip()
            party = s.split('(')[1].split(')')[0].lower().strip()
        if re.search(MINISTER_RE, s):
            name = '_'.join(s.split()[1:-1]).lower().strip()
            party = 'statsrad'
        timestamp = '_'.join(s.split('[')[1].split(']')[0].split(':'))
        return (name, party, timestamp)
    except Exception as e:
        print '[ PARSING ] Error:', e
        print "[ PARSING ] Got:", s
        return ('junk', 'junk', 'junk') 

class StortingetParser(HTMLParser):
    def __init__(self, day):
        HTMLParser.__init__(self)
        self.day = day
        self.speaker_flag = False
        self.collecting_flag = False
        self.speaker = ''
        self.party = ''
        self.timestamp = ''

    def handle_starttag(self, tag, attrs):
        if tag == 'span' and ('class', 'ref-presidenten') in attrs:
            self.speaker_flag = True
            self.collecting_flag = False
            print "[ PARSING ] SPEAKER: Presidenten"
            self.speaker = 'presidenten'
            self.party = 'pres'
        elif tag == 'a' and ('class', 'ref-innlegg-navn') in attrs:
            self.speaker_flag = True
            self.collecting_flag = False
        elif tag == 'a' and ('id', 'votering') in attrs:
            self.collecting_flag = False
        else:
            self.speaker_flag = False

    def handle_data(self, data):
        if self.collecting_flag:
            print "[ PARSING ]\tTEXT:", data.encode('utf8')
            ensure_dir("data/processed/%s" % (self.party))
            ensure_dir("data/processed/%s/%s" % (self.party, 
                                                 self.speaker))
            ensure_dir("data/processed/%s/%s/%s" % (self.party, 
                                                    self.speaker, 
                                                    self.day))
            safewrite("data/processed/%s/%s/%s" % (self.party,
                                                   self.speaker,
                                                   self.day),
                      self.timestamp,
                      data)
        if self.speaker_flag:
            self.collecting_flag = True
            if self.speaker != 'presidenten':
                print "[ PARSING ] SPEAKER DATA:", data.encode('utf8')
                self.speaker_flag = False
                self.speaker, self.party, self.timestamp = parse_stortinget_speaker(data)
                print '[ PARSING ] SPEAKER:', self.speaker.encode('utf8')
                print '[ PARSING ] PARTY:', self.party.encode('utf8')
                print '[ PARSING ] TIMESTAMP', self.timestamp.encode('utf8')

def horinger(top_level_dir):
    raise NotImplementedError()

def stortinget(top_level_dir):
    for root, dirnames, filenames in os.walk(top_level_dir):
        for f in filenames:
            parser = StortingetParser(top_level_dir.split('/')[8])
            file_path =  os.path.join(root, f)
            print "[ STARTING ] file path: ", file_path
            parser.feed(codecs.open(file_path, 'r', 'utf8').read())

if __name__ == '__main__':
    man = "usage python /scripts/cleanup.py {stortinget|horinger} dir"
    if len(sys.argv) < 3:
        print man
        sys.exit()
    if sys.argv[1] == 'stortinget':
        stortinget(sys.argv[2])
    else:
        horinger(sys.argv[2])