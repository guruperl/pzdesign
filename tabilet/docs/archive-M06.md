# Archive M06 - Cross-Party Access Control And Channel Policy

**Context.** Ownership of the relationships that decide which demand may
transact with which supply: the direct block and allow relationships between
publishers, advertisers, sites, campaigns, and slots, and the content-channel
taxonomy layered on top of them.

**Baseline.** `d67ea8ac35b0578db9674bfbb40fede56954cddf`

**Coverage.** verified

**Supersedes.** none

## Scope And Responsibilities

This context owns `summer/ac`, `summer/chac`, and `summer/channel`, together
with the access-control templates under `tmpls/adv/ac` and `tmpls/pub/ac`.

It excludes the advertiser and publisher objects these relationships reference,
which are M04 and M05, and it excludes auction-time enforcement, which is
Aofei's. The archive records how the relationship rows are maintained, not how
they are applied to a bid.

## Domain And Workflows

Access control is symmetric and typed rather than one-directional. Both sides may
express a relationship, and every row names an entity type and id on each side.
The shared type vocabulary is small and closed: `3` publisher, `4` advertiser,
`31` site, `32` slot, `41` campaign, `42` ad-group. In practice a publisher or
its site expresses a relationship toward an advertiser or campaign, and an
advertiser or its campaign expresses one toward a site.

The meaning of the stored rows is not fixed by the rows themselves. Each owning
entity carries an `access_order` column that decides whether its list is read as
an allow list or a block list, which is why changing that order and clearing the
existing rows happen in the same operation: switching interpretation without
discarding the old list would silently invert the policy.

Bulk assignment is a replace, not an accumulate. `Inserts` reduces the submitted
advertiser and campaign ids to unique digit strings, drops any campaign already
covered by one of the selected advertisers, deletes the entity's existing rows,
then writes the new set in one statement. Single insert is idempotent: it looks
for an existing row on the full four-column key and only inserts when none
exists.

Channels are a separate two-relation taxonomy over the same entity vocabulary,
restricted to slots and ad-groups. `ch_belong` records which channels an object
belongs to and `ch_ac` records which channels it accepts or excludes, with a
`channel_order` column playing the same interpretation role that `access_order`
plays for direct relationships. Update rejects an empty `channel_order` for slot
and ad-group entities rather than defaulting it. The channel dictionary itself is
a levelled tree in `def_channel` with a parent and a full name, and topic
listings default to level 1 to keep the picker short.

Slot writes are the main caller: slot insert and update delegate channel
belonging and channel access effects to `chac` through the model's nested-call
mechanism, and slot forms carry `belong_ids` and `ac_ids`.

## System Shape

- `summer/ac` maps `entitytype_id` through the shared `summer.TABLES` map to a
  table and id column before touching `access_order`, so an unknown type is an
  error rather than an interpolation.
- Dynamic SQL in this context is confined to placeholder generation and to table
  and id-column names resolved from that closed map; all values stay
  parameterized.
- `summer/chac` reads `channel_order` from `pub_slot` or `adv_item` depending on
  entity type and builds a left-joined listing of the channel dictionary against
  both relation tables.
- `summer/channel` is the administrator-maintained dictionary over
  `def_channel` with channel id, name, level, parent, and full name.
- `tmpls/adv/ac` and `tmpls/pub/ac` render the two sides of the same
  relationship, including the `updateOrder` form that switches interpretation.

## Contracts And Dependencies

- `summer.TABLES` is the single source of the entity-type vocabulary shared with
  advertiser and publisher filters, which set `entitytype_id` to `41`, `42`, and
  `32` on their own writes.
- `Model.CallOnce` is the nested-call contract used by slot writes to run
  `chac.insertBelong`, `chac.insertAc`, and `chac.update` inside the slot
  request.
- The `ac`, `ch_belong`, `ch_ac`, and `def_channel` tables and the `access_order`
  and `channel_order` columns are defined in Aofei's schema.
- `summer.TranslateOne` supplies the Chinese channel labels used by slot forms.

## Operations And Verification

`summer/ac` and `summer/chac` both carry filter tests that pass at this
baseline. `summer/channel` has no test file and is exercised through the
registry correspondence check and the template parser.

## Evidence

| Claim | Repository Evidence |
|---|---|
| The closed entity-type vocabulary shared across contexts. | `summer/filter.go:121-128`, `summer/ac/model.go:1-22` |
| Entity type resolves to a table and id column or fails. | `summer/ac/model.go:65-71` |
| Single insert is idempotent on the four-column relationship key. | `summer/ac/model.go:82-94` |
| Bulk assignment de-duplicates, drops covered campaigns, and replaces. | `summer/ac/model.go:96-142` |
| Changing `access_order` clears the existing rows in the same operation. | `summer/ac/model.go:144-164` |
| Channel relations are restricted to slot and ad-group entities. | `summer/chac/model.go:37-60`, `summer/chac/model.go:110-120` |
| Channel listings default to level 1 of the dictionary tree. | `summer/chac/model.go:62-83` |
| The two channel relations are separate belong and access tables. | `summer/chac/model.go:84-108` |
| The channel dictionary shape. | `summer/channel/component.json` |
| Slot writes delegate channel effects through nested model calls. | `summer/slot/filter.go:236-265` |

## Observed Gaps

`summer/channel` has no template directory of its own, so no in-repo evidence
shows where the channel dictionary is edited in the UI. The semantics of a
specific `access_order` or `channel_order` value — which value means allow and
which means block — are not recorded in this repository; the columns are read
and written here but interpreted by Aofei at auction time.
