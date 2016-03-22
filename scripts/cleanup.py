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

# </p><p class="ref-uinnrykk"><a id="a3.2" class="ref-innlegg-navn"><!-- TALERINITIALER="TROH", TALETIDSPUNKT="10:56:33" -->Trond Helleland (H) [10:56:33]:</a> Jeg brukte ganske store deler av mitt innlegg på å forklare nettopp det, men jeg kan godt gjenta det.

def ensure_dir(f):
    if not os.path.exists(f):
        os.makedirs(f)
        print "created directory %s" % (f)

def safewrite(d, f, data):
    aw = 'w'
    if os.path.exists(os.path.join(d, "%s.txt" % (f))):
        aw = 'a'
    try:
        with codecs.open(os.path.join(d, "%s.txt" % (f)), aw, 'utf8') as out:
            out.write(data + '\n\n')
    except IOError as e:
        print "Got IOError: %s" % (e)

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
        print 'ERROR:', e
        print "GOT JUNK:", s
        return ('junk', 'junk', 'junk') 

class HoringerParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.current_tag = None
        self.speaker = None
        self.party = None
        self.text_counter = 0
    def handle_starttag(self, tag, attrs):
        self.current_tag = tag
        #print "Encountered a start tag:", tag
    def handle_endtag(self, tag):        
        # print "Encountered an end tag :", tag
        pass
    def handle_data(self, data):
        if self.current_tag not in RUBBISH and len(data) > 1:
            # print 'Data:', data
            if re.search(NAME_PARTY_RE, data):
                self.speaker = data.split('(')[0].strip()
                self.party = data.split('(')[1].split(')')[0]
            if self.speaker and len(self.party) < 4:
                self.text_counter += 1
                if self.text_counter == 2:
                    print "Got speaker:", self.speaker.encode('utf8')
                    print "party:", self.party.encode('utf8')
                    print "says:", data.encode('utf8')
                    ensure_dir("data/processed/%s" % (self.party.lower()))
                    safewrite("data/processed/%s" % (self.party.lower()), '_'.join(self.speaker.split()), data)
                    self.speaker, self.party, self.text_counter = (None, None, 0)

class StortingetParser(HTMLParser):
    def __init__(self):
        HTMLParser.__init__(self)
        self.speaker_flag = False
        self.collecting_flag = False
        self.speaker = ''
        self.party = ''
        self.timestamp = ''
        self.day = ''
    def handle_starttag(self, tag, attrs):
        if tag == 'span' and ('class', 'ref-presidenten') in attrs:
            self.speaker_flag = True
            self.collecting_flag = False
            print "SPEAKER: Presidenten"
            self.speaker = 'presidenten'
            self.party = 'pres'
        elif tag == 'a' and ('class', 'ref-innlegg-navn') in attrs:
            self.speaker_flag = True
            self.collecting_flag = False
        elif tag == 'a' and ('id', 'votering') in attrs:
            self.collecting_flag = False
        else:
            self.speaker_flag = False
        #print "Encountered a start tag:", tag
    def handle_endtag(self, tag):
        # print "Encountered an end tag :", tag
        pass

    def handle_comment(self, data):
        pass
        #if 'TALERINITIALER' in data:
        #    self.speaker_flag = True
        #    self.collecting_flag = False

    def handle_data(self, data):
        if self.collecting_flag:
            print "WORDS:", data.encode('utf8')
        if self.speaker_flag:
            self.collecting_flag = True
            if self.speaker != 'presidenten':
                print "SPEAKER DATA:", data.encode('utf8')
                self.speaker_flag = False
                self.speaker, self.party, self.timestamp = parse_stortinget_speaker(data)
                print 'SPEAKER:', self.speaker.encode('utf8')
                print 'PARTY:', self.party.encode('utf8')
                print 'TIMESTAMP', self.timestamp.encode('utf8')

def horinger(top_level_dir):
    for root, dirnames, filenames in os.walk(top_level_dir):
        for f in filenames:
            parser = HoringerParser()
            file_path =  os.path.join(root, f)
            print "file absolute path: ", file_path
            parser.feed(codecs.open(file_path, 'r', 'utf8').read())

def stortinget(top_level_dir):
    for root, dirnames, filenames in os.walk(top_level_dir):
        for f in filenames:
            parser = StortingetParser()
            file_path =  os.path.join(root, f)
            print "file absolute path: ", file_path
            parser.feed(codecs.open(file_path, 'r', 'utf8').read())

if __name__ == '__main__':
    man = "usage python /scripts/cleanup.py {stortinget|horinger} dir"
    if len(sys.argv) < 3:
        print man
        sys.exit()
    if sys.argv[1] != 'stortinget' or sys.argv[1] != 'horinger':
        print man
        sys.exit
    if sys.argv[1] == 'stortinget':
        stortinget(sys.argv[2])
    else:
        horinger(sys.argv[2])