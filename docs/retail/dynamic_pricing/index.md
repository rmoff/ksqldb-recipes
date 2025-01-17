---
seo:
  title: Set Dynamic Pricing
  description: This recipe demonstrates how to use ksqlDB to set dynamic pricing in an online marketplace
---

# Set Dynamic Pricing

## What is it?

An online marketplace keeps track of statistics regarding pricing: lowest, median, etc.
These statistics enable buyers and sellers to make dynamic offers based on historical sales events.

## Get Started

--8<-- "docs/shared/ccloud_launch.md"

<a href="https://www.confluent.io/confluent-cloud/tryfree/"><img src="../../img/launch.png" /></a>

## Step-by-Step

### Setup your Environment

--8<-- "docs/shared/ccloud_setup.md"

### Read the data in

--8<-- "docs/shared/connect.md"

For this recipe, we are interested in knowing each marketplace event for an item, specifically its pricing. 
This creates a stream of events, upon which real-time stream processing can keep state and calculate pricing statistics.

```sql
--8<-- "docs/retail/dynamic_pricing/source.sql"
```

--8<-- "docs/shared/manual_insert.md"

### Run stream processing app

```sql
--8<-- "docs/retail/dynamic_pricing/process.sql"
```

--8<-- "docs/shared/manual_cue.md"

```sql
--8<-- "docs/retail/dynamic_pricing/manual.sql"
```

## Full ksqlDB Statements

--8<-- "docs/shared/code_summary.md"

```sql
--8<-- "docs/retail/dynamic_pricing/source.sql"

--8<-- "docs/retail/dynamic_pricing/process.sql"
```
