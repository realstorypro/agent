# The Agent 🥷
"Nobody can give you freedom. Nobody can give you equality or justice or anything. If you're a man, you take it." — Malcom X

### Features
- [ ] Distributed Crunchbase Companies Prospecting
- [x] Distributed Crunchbase Company Scrape
- [x] Contact Enrichment
- [x] Customer.Io Upload

## Setup
1. Setup _mitmproxy_

```bash
brew install mitmproxy
```

2. Start the _mitmproxy_ to disable peremetrix
 
```bash
 mitmproxy -s mitmproxy/crunchbase.py  
```

3. Setup ENV file (including AGENT_CODENAME)

## Usage

### Scraping Crunchbase
1. Take companies to scrape (550 Max)
```bash
rake agent:take
```

2. Scrape with the following command
```bash
rake crunchbase:scrape
```

### Uploading to Customer
1. Enrich the contacts (/w geolocation info)
```bash
rake contacts:enrich
```

2. Find & verify email addresses
```bash
rake contacts:find_email
```

3. Upload the contacts to customer.io
```bash
rake contacts:upload
```
