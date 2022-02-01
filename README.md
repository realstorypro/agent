# The Agent 🥷
"Nobody can give you freedom. Nobody can give you equality or justice or anything. If you're a man, you take it." — Malcom X

### Features
- [ ] Distributed Crunchbase Contact Scrape (w/ Airtable Sync)
- [ ] Distributed Crunchbase Companies Prospecting (w/ Airtable Sync)
- [ ] Contact Enrichment
- [ ] Customer.Io Upload

### Setup
1. Setup _mitmproxy_

```bash
brew install mitmproxy
```

2. Start the _mitmproxy_ to disable peremetrix
 
```bash
 mitmproxy -s mitmproxy/crunchbase.py  
```