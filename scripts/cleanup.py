import os
import codecs
import re
from HTMLParser import HTMLParser


RUBBISH = ['script', 'meta']
SPEAKER_RE = re.compile(".+\(.+\):", re.UNICODE)

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

class MyHTMLParser(HTMLParser):
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
            if re.search(SPEAKER_RE, data):
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

# instantiate the parser and fed it some HTML
# parser = MyHTMLParser()
# parser.feed('<html><head><title>Test</title></head>'
#             '<body><h1>Parse me!</h1></body></html>')

for root, dirnames, filenames in os.walk("data/"):
    parser = MyHTMLParser()
    for f in filenames:
        file_path =  os.path.join(root, f)
        print "file absolute path: ", file_path
        parser.feed(codecs.open(file_path, 'r', 'utf8').read())