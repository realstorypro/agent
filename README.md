# The Agent 🥷
"Nobody can give you freedom. Nobody can give you equality or justice or anything. If you're a man, you take it." — Malcom X

### Features
- [x] Companies Prospecting
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

### Prospecting Crunchbase
1. Build a list
```bash
rake list:build
```

2. Upload the list
```bash
rake list:upload
```

### Scraping Crunchbase
1. Take companies to scrape (550 Max)
```bash
rake agent:take
```

2. Scrape with the following command
```bash
rake crunchbase:scrape
```

### Uploading to Customer.io
_Note:_ This uploads __all__ contacts not just the ones assigned to the agent. It's best to run this after 5pm (MST) so that we can run enchance right after

```bash
rake contacts:process
```

### Enrich contacts w/ Timezone info
```bash
rake contacts:enrich 
```
