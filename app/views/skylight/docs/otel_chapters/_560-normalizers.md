---
title: Normalizers
description: Adjusting trace data with user-defined normalizers
---

## Introduction to Normalizers

The [OpenTelemetry Semantic Convention][otel-semconv] provides a way for tools like Skylight to make sense of the meaning of data encoded in Otel traces. In general, we try to make good use of this standard to extract useful information from traces into the Skylight data model.

This requires the incoming traces to be compliant to the latest version of the standard. However, this is not always the case. The standard is still in its infancy and goes through rapid changes. It is not uncommon for instrumentation code in apps and libraries to lag behind and emit metadata in outdated format. Sometimes, this is even deliberately as the data may need to be consumed by other tools that expects it.

At other times, the Otel data model and semantic convention may not offer enough useful information to extract useful data for Skylight. While we provide a way to directly control the mapping with Skylight-specific attributes, it is often impractical or undesirable to add the attributes directly to the source code.

To bridge these gaps, the Skylight Otel agent includes a flexible normalizer system for manipulating the incoming data.

## Built-in Normalizers Rules

In the interest of transparency and making the system more understandable, the Skylight Otel comes with some built-in rules. Their source code is published on GitHub.

<!-- TODO link -->

<!-- TODO disabling built-in rules, presets -->

## Custom Normalizer Rules

A normalizer rule consists of:

1. A _matcher_ to target incoming spans matching the given conditions; then
2. Execute some _actions_ to add, remove or change one or more associated attributes on the target spans.

For example, this rule targets spans with the `"http.response.status_code"` attribute. Depending the value of this attribute, it may split the trace into a "redirect" or "error" segment. This can improve aggregation as it separate traces with potentially divergent behavior from the happy path:

```toml
[[rules]]
# Spans with a HTTP response code between 300 and 400
match = { key = "$span[http.response.status_code]", value = { gte = 300, lt = 400 } }
"$span[skylight.trace.segment]" = "redirect"

[[rules]]
# Spans with a HTTP response code of 400 or 500
match = { key = "$span[http.response.status_code]", value.gte = 400 }
"$span[skylight.trace.segment]" = "error"
```

As illustrated here, custom normalizer rules are written in [TOML][toml]. To start, you can write these rules directly in the `skylight.toml` config file under the `normalizer.rules` key, but if you need more than a handful of these, you may prefer to organize them as individual TOML files in a `normalizers` directory adjacent to `skylight.toml`, in which case, you'd just use the `rules` key as shown here. The examples in this chapter will assume the latter.

A note on TOML syntax. TOML is designed to be easy to read. As such, there are often equivalent ways to express the same item for readability. For instance, the example above is equivalent to the following:

```toml
[[rules]]
match.key = "$span[http.response.status_code]"
match.value = { gte = 300, lt = 400 }
"$span[skylight.trace.segment]" = "redirect"

[[rules]]
match = { key = "$span[http.response.status_code]", value = { gte = 400 } }
"$span[skylight.trace.segment]" = "error"
```

See the [TOML documentation][toml-spec] for more details. Note that the current version version of TOML does not permit breaking up "inline tables" (`{ ... }`) into multiple lines. This feature is [planned][toml-multiline-tables] for TOML 1.1, but the spec has not yet been released and our TOML parser does not allow it.

## Matcher

As explained above, every normalizer rule begins with a `match` key, called the _matcher_ clause.

### Match Always/Never

The simplest matcher clause is the `always` syntax:

```toml
[[rules]]
# this matches all spans
match.always = true

[[rules]]
# this never matches any spans
match.always = false

# ...alternatively, the shorthand version...

[[rules]]
# same as match.always = true
match = true

[[rules]]
# same as match.always = false
match = false
```

This is mostly useful to quickly test or disable a rule.

### Match Key/Value

The most common matcher clause is the key-value matcher:

```toml
[[rules]]
# this matches any spans with the "foo.bar" attribute, regardless of its value
match.key = "$span[foo.bar]"

[[rules]]
# this matches any spans with the "foo.bar" attribute, but only if its value is
# equal to "some value"
match.key = "$span[foo.bar]"
match.value = "some value"

# ...alternatively, TOML also permits the above to be written as...

[[rules]]
# same as above
match = { key = "$span[foo.bar]", value = "some value" }
```

The string `"$span[foo.bar]"` to the right-hand side of `key` is a _reference_. We will go into more details about references in a subsequent section. For now, just understand that this is targeting the `"foo.bar"` attribute on a span.

The `value` key in this context is called a _value matcher_ clause. While the `key` is required, `value` is optional. If omitted, it simply checks for the presence of that attribute regardless of the value of that attribute.

The simplest value matcher, as shown in this example, is a simple _primitive_ value (a string, a number, or a boolean value), which just checks for simple equality on the attribute value. However, other value matchers are available for more complex and targeted matching.

### Value Matcher: Comparisons (`eq`, `gt`, `gte`, `lt`, `lte`) and Ranges

The `eq` (equals) value matcher is the explicit longhand form and does the same thing as the more concise example above. It's mostly provided for completeness.

```toml
[[rules]]
match = { key = "$span[foo.bar]", value.eq = "some value" }

[[rules]]
match = { key = "$span[foo.bar]", value = "some value" }
```

The `gt` (greater than), `gte` (greater than or equal to), `lt` (less than), `lte` (less than or equal to) value matchers works similarly, but does the corresponding comparison on the attribute value rather than simple equality. They are mostly useful for comparing numeric values, though they can be used for strings (lexicographical comparisons) as well:

```toml
[[rules]]
# $span[foo.bar] > 5
match = { key = "$span[foo.bar]", value.gt = 5 }

[[rules]]
# $span[foo.bar] >= 5
match = { key = "$span[foo.bar]", value.gte = 5 }

[[rules]]
# $span[foo.bar] < 5
match = { key = "$span[foo.bar]", value.lt = 5 }

[[rules]]
# $span[foo.bar] <= 5
match = { key = "$span[foo.bar]", value.lte = 5 }
```

As an extension to the above, you can also do range comparisons by pairing one of `gt`/`gte` with one of `lt`/`lte`:

```toml
[[rules]]
# $span[foo.bar] > 5 and < 10
match = { key = "$span[foo.bar]", value = { gt = 5, lt = 10 } }

[[rules]]
# $span[foo.bar] >= 5 and < 10
match = { key = "$span[foo.bar]", value = { gte = 5, lt = 10 } }
```

Note that this feature is specific to valid ranges, you cannot arbitrarily combine value matchers this way.

### Value Matcher: Data Types (`is`)

The `is` value matcher allows for matching attribute values based on its data type.

```toml
[[rules]]
# $span[foo.bar] is a string
match = { key = "$span[foo.bar]", value.is.string = true }

[[rules]]
# $span[foo.bar] is not a string
match = { key = "$span[foo.bar]", value.is.string = false }
```

Here are all the available `is` matchers:

* `is.bool` – the value is a boolean
* `is.int` – the value is an integer
* `is.float` – the value is a floating point value
* `is.string` – the value is a string
* `is.number` – the value is a number (either integer or floating point)
* `is.present` – the value is present (not `null`)

Note that `value.is.present = true` is just the explicit longhand form of omitting the value matcher altogether, and is mostly provided for completeness.

### Value Matcher: Regular Expressions (`matches`)

The `matches` value matcher matches a string attribute against a regular expression (regex):

```toml
[[rules]]
# $span[foo.bar] =~ /some (.+) value/
match = { key = "$span[foo.bar]", value.matches = "some (.+) value" }

[[rules]]
# same as above
match = { key = "$span[foo.bar]", value.matches.regex = "some (.+) value" }
```

Note that this implicitly requires the attribute value to be a string. If the value is anything other than a string, this matcher will not match.

See the dedicated section on regular expressions on topics like flags (e.g. case-sensitivity) and capture groups.

### Value Matcher: Version Ranges (`matches.version`)

The `matches.version` value matcher matches a string attribute against a version range:

```toml
[[rules]]
# $span[foo.bar] satisfies "~1.2.3"
match = { key = "$span[foo.bar]", value.matches.version = "~1.2.3" }
```

Some examples of the supported syntaxes are:

* `=1.2.3`: matches the version `1.2.3` exactly
* `>=1.2.3`: any version including and above version `1.2.3`
* `~1.2.3`: matches any versions `>=1.2.3` but `<1.3.0`
* `^1.2.3`:[Semantic Versioning][semver] compatibility: `>=1.2.3` but `<2.0.0`
* `1.2.3`: a shorthand for `^1.2.3` (**not** `=1.2.3`)
* `1.*`: matches any versions within the major version 1
* `*`: matches any valid versions

Note that this implicitly requires the attribute value to be a string, **and** that it can be parsed as a valid version number. If the value is anything other than a string or cannot be parsed, this matcher will not match.

### Combinators

Sometimes you need to specify a complex condition – inverting a matcher, or combining multiple matches to reach the specificity required for your rule.

This can accomplished with _combinators_.

#### Combinator: `not`

The `not` combinator inverts a matcher. Some examples:

```toml
[[rules]]
# Never matches. A bit silly as an example, but shows that you can always
# change from `match` to `match.not` to invert the entire matcher.
match.not.always = true

[[rules]]
# $span[foo.bar] != "foo" – this is a more practical example as it would
# otherwise be impossible to express.
match = { key = "$span[foo.bar]", value.not.eq = "foo" }

[[rules]]
# $span[foo.bar] !~ /some (.+) value/
match = { key = "$span[foo.bar]", value.not.matches = "some (.+) value" }

[[rules]]
# $span[foo.bar] is any valid version other than "=1.2.3"
match = { key = "$span[foo.bar]", value.not.matches.version = "=1.2.3" }

[[rules]]
# equivalent to `value.is.string = false`
match = { key = "$span[foo.bar]", value.is.not.string = true }
```

#### Combinator: `any`

The `any` combinator accepts an array and will match if any of the conditions are satisfied:

```toml
[[rules]]
match.any = [
  { always = true },
  # This is never executed, because the first condition always matches
  { key = "$span[foo.bar]", value.matches = "some (.+) value" },
]

[[rules]]
# equivalent to value.is.number = true
match = { key = "$span[foo.bar]", value.is.any = [{ int = true }, { float = true }] }

[[rules]]
# more or less equivalent to matching "(first .+)|(second)|(.+ third)"
match.key = "$span[foo.bar]"
value.matches.any = [
  "first .+",
  "second",
  ".+ third",
]

[[rules]]
# $span[foo.bar] != "hello", or is a string, or satisfies "1.*"
match.key = "$span[foo.bar]"
match.value.any = [
  { not.eq = "hello" },
  { is.string = true },
  { matches.version = "1.*" },
]
```

#### Combinator: `all`

The `all` combinator accepts an array and will match only of all the conditions are satisfied:

```toml
[[rules]]
match.all = [
  { not.always = true },
  # This is never executed, because the first condition never matches
  { key = "$span[foo.bar]", value.matches = "some (.+) value" },
]

[[rules]]
# redundant, since is.present is implied by is.string, but works
match = { key = "$span[foo.bar]", value.is.all = [{ present = true }, { string = true }] }

[[rules]]
# matches all of these regex at the same time
match.key = "$span[foo.bar]"
value.matches.all = [
  "first .+",
  "second",
  ".+ third",
]

[[rules]]
# $span[foo.bar] is a string, but not "hello", and not a valid version
match.key = "$span[foo.bar]"
match.value.all = [
  { is.string = true },
  { not.eq = "hello" },
  { not.matches.version = "*" },
]
```

## Actions

The second part of a normalizer rule is to execute some _actions_ on that matched span.

### Action: Assignments

The most common action is to assign an attribute on the matched span. This allows you to add new attributes, change the value of existing attributes or remove some attributes entirely.

```toml
[[rules]]
# Match spans with the "foo.bar" attribute, unconditionally replace its value
# with the string "foo bar"
match = { key = "$span[foo.bar]" }
"$span[foo.bar]" = "foo bar"
```

```toml
[[rules]]
# Match spans with the "foo.bar" attribute with the value `true`, change it to
# `false`
match = { key = "$span[foo.bar]", value = true }
"$span[foo.bar]" = false
```

```toml
[[rules]]
# Match spans with the "foo.bar" attribute, keep it and assign its value to a
# different attribute "bar.baz"
match = { key = "$span[foo.bar]" }
"$span[bar.baz]" = "$span[foo.bar]"
```

```toml
[[rules]]
# Match spans with the "foo.bar" attribute, setting its value to `null`,
# effectively remove the attribute
match = { key = "$span[foo.bar]" }
"$span[bar.baz]" = "$null"
```

```toml
[[rules]]
# Match spans with the "foo.bar" attribute, assign its value to a different
# attribute "bar.baz" and `null`-ing out "foo.bar"
match = { key = "$span[foo.bar]" }
"$span[foo.bar]" = "$null"
"$span[bar.baz]" = "$span[foo.bar]"
```

A few things to note here:

1. Assignment keys must be a reference to a **span attribute**. Because the `$` and `.` characters are not valid in TOML keys, assignment keys need to be quoted.

2. Strings that begin with `$` are treated as references. To assign a literal strings beginning with a `$` character requires escaping, this is covered in a later section.

3. Because TOML does not have a way to represent `null`, we need to special `$null` reference. That and other reference are covered in a later section.

4. Within the same rule, the ordering of the assignments are irreverent – references always refer to the incoming value, and the "effect" of the assignments cannot be observed within the normalizers system.

   This can be seen in action in the last example above – even though the rule assigns `$null` to `$span[foo.bar]`, it does not prevent the other assignment to `$span[bar.baz]` from successfully referencing the _original_ value of the `"foo.bar"` attribute in the incoming Otel span. Those assignments will have exactly the outcome in either of the two possible ordering in the TOML.

If a span is matched by multiple rules, and multiple of them assigns the same attribute, then normally, the last rule (in the TOML `rules` array order) with that assignment prevails. For instance:

```toml
[[rules]]
match = { key = "$span[foo.bar]" }
"$span[common.target]" = "first"

[[rules]]
match = { key = "$span[foo.bar]", value.is.string = true }
"$span[common.target]" = "second"

[[rules]]
match = { key = "$span[foo.bar]", value = "special" }
"$span[common.target]" = "third"
```

In this example, since all three rules try to assigns the `"common.target"` attribute:

1. On a span without the `"foo.bar"` attribute, none of these matches, so the `"common.target"` attributes doesn't get assigned by these rules

2. On a span with the `"foo.bar"` set to a non-string value, only the first rule matches, thus the `"common.target"` attributes is ultimately assigned with the value `"first"`

3. On a span with the `"foo.bar"` set to a string value other than `"special"`, only both the first and second rules matches, thus the `"common.target"` attributes is ultimately assigned with the value `"second"`, as the latter rule prevails

4. On a span with the `"foo.bar"` set to the string `"special"`, all three rules matches, thus the `"common.target"` attributes is ultimately assigned with the value `"third"`, as the last rule prevails

This behavior can be influenced by specifying an _assignment mode_:

```toml
[[rules]]
match = { key = "$span[foo.bar]" }
"$span[common.target]" = { mode = "final", value = "first" }

[[rules]]
match = { key = "$span[foo.bar]", value.is.string = true }
"$span[common.target]" = { mode = "normal", value = "second" }

[[rules]]
match = true
"$span[common.target]" = { mode = "default" , value = "third" }
```

1. The `normal` assignment mode is the normal behavior described previously

2. The `final` assignment mode prevents later rules from reassigning the same attribute, essentially flipping things around such that the first matched rule (in the TOML `rules` array order) prevails

3. The `default` assignment mode only applies if the attribute is `null`, either because it was not present in the incoming span, or an earlier rule explicitly removed it. Note that if the previous rule assigned the `null` value as with `final`, that prevents this `default` assignment from taking effect.

This feature is not typically used in custom normalizers – since you are free to re-order your rules in your TOML file, that is often the easier and clearer way to accomplish the desired outcome. However, since the built-in normalizer rules are prepended to your custom rules, you may see this feature used in the built-in rules from time to time.

### Action: Ignoring a Trace

Instead of assigning attributes, a custom rule can also elect to ignore the current trace:

```toml
[[rules]]
# If any span in the current trace has this attribute, drop the whole trace
match = { key = "$span[foo.bar]" }
ignore_trace = true
```

This can also be set to a string indicating the reason for ignoring the trace, which may be shown in the agent logs.

### Action: Ignoring a Span

A custom rule can also elect to ignore the matched span:

```toml
[[rules]]
# Drop any spans with this attribute
match = { key = "$span[foo.bar]" }
ignore_trace = true
```

This can also be set to a string indicating the reason for ignoring the span, which may be shown in the agent logs.

## Literals

You have already seen the various type of literal values in action, this section will cover each of them a bit more in-depth.

### Literal: null

The `null` value denotes the absence of data. For example, a span attribute reference to a non-existent attribute will result in the `null` value:

```toml
[[rules]]
# Always overwrite any span with a "foo.bar" attribute with the value from the
# "bar.baz" attribute on the same span. If the current span does not have a
# "bar.baz" attribute, it will result in assigning `null`.
match.key = "$span[foo.bar]"
"$span[foo.bar]" = "$span[bar.baz]"
```

Since the `null` value cannot be referenced directly from TOML syntax, the special reference `$null` always contains the value `null`.

### Literal: bool

Boolean values are either `true` or `false`.

Note that they are not the same as the string `"true"` and `"false"`.

### Literal: int

Integer values are represented as signed 64-bit integers internally, values outside that range are not supported.

The TOML syntax provides some [additional affordances][toml-integers] for integer literals.

### Literal: float

Float values are represented as 64-bit double-precision floating points internally.

The TOML syntax provides some [additional affordances][toml-floats] for floating point values.

### Literal: string

String literals have some additional features and caveats over normal [TOML string][toml-strings].

1. Strings that being with `$` are considered _references_ (covered in more details later) are are subject to their own syntactic rules. To produce a verbatim string that starts with the character `$`, it can be escaped with `$$`. For example:

   ```toml
   [[rules]]
   # This assigns the verbatim string "$ not a reference". Without the extra $,
   # this would have been a syntax error.
   match = true
   "$span[foo.bar]" = "$$ not a reference"
   ```

2. Strings can be interpolated:

   ```toml
   [[rules]]
   # This assigns the concatenation of "hello " + $span[user.name] + " there".
   match = true
   "$span[foo.bar]" = "hello {$span[user.name]} there"

   [[rules]]
   # An interpolated string can have more than one dynamic segments.
   match = true
   "$span[foo.bar]" = "{$span[first]} {$span[second]} {$span[third]}"
   ```

3. As a result, verbatim strings that contains the `{` and `}` characters would need to escape them with `{{` and `}}` respectively:

   ```toml
   [[rules]]
   # This assigns the verbatim string "This is {not interpolated}!". Without
   # the extra { and }, this would have been a syntax error.
   match = true
   "$span[foo.bar]" = "This is {{not interpolated}}!"
   ```

### Literal: Regular Expressions

Regular expressions are special string literals that can be used in the `value.matches.regex` value matcher and the `replace` expression (to be covered later).

Since regular expressions literals sometimes contain characters that require escaping in the TOML syntax, you may find the TOML single quote literal strings syntax useful here.

Regular expressions can contain capture groups. The captured values from the most recent regular expression match within the current rule can be referenced through the `$match[*]` references:

```toml
[[rules]]
match = { key = "$span[foo.bar]", value.matches = '^([^@]+)@(.+)$' }
# The entire match
"$span[email]" = "$match[0]"
# The recipient portion of an email address (before the @)
"$span[email.user]" = "$match[1]"
# The domain of an email address (after the @)
"$span[email.domain]" = "$match[2]"
```

Capture groups can also be named:

```toml
[[rules]]
match = { key = "$span[foo.bar]", value.matches = '^(?<user>[^@]+)@(?<domain>.+)$' }
# The entire match
"$span[email]" = "$match[0]"
# The recipient portion of an email address (before the @)
"$span[email.user]" = "$match[user]"
# The domain of an email address (after the @)
"$span[email.domain]" = "$match[domain]"
```

If a `$match[*]` references refers to a non-existing capture group, or the last regex match failed to produce a match, then these references will evaluate to the value `null`.

Regular expressions can also change its matching behavior with one or more of these flags (all disabled by default):

* `i`: case-insensitive: letters match both upper and lower case
* `m`: multi-line mode: `^` and `$` match begin/end of line
* `s`: allow `.` to match `\n`
* `R`: enables CRLF mode: when multi-line mode is enabled, `\r\n` is used
* `U`: swap the meaning of `x*` and `x*?`
* `x`: verbose mode, ignores whitespace and allow line comments (starting with `#`)

These flags can be enabled and disabled anywhere in the regex:

```toml
[[rules]]
# Enabling the case-insensitive flag for this entire regex
match = { key = "$span[foo.bar]", value.matches = '(?i)cAsE dOeS nOt MaTtEr' }

[[rules]]
# Enabling the case-insensitive flag for part of the regex
match = { key = "$span[foo.bar]", value.matches = 'case (?i)dOeS nOt(?-i) matter' }

[[rules]]
# Enabling the case-insensitive flag inside a group
match = { key = "$span[foo.bar]", value.matches = 'case (?i:dOeS nOt) matter' }
```

## References

So far, we have seen a few type of references used in the examples. This section will cover the different types of references in-depth.

### Span Attribute References (`$span[*]`)

Span attribute references (`$span[foo.bar]`) is the most common reference type. It refers to an attribute with that name (`"foo.bar"` here) on the incoming span, and resolves to the value of that attribute if it exist on the span, or `null` otherwise.

Span attribute references are the only type of reference that can be assigned to, all other references are read-only. Further, assigning to a span attribute reference does not change its value immediately – the effect of the assignment is not visible within the normalizers system; an attribute reference always resolve to original value on the incoming span.

### Scope Attribute References (`$scope[*]`)

Scope attribute references (`$scope[foo.bar]`) refers to attributes on the instrumentation scope associated with a span.

Note that it is quite common for an instrumentation scope to be associated with multiple spans (e.g. all spans produced by the same library), so using a scope attribute reference as the `key` for a matcher clause as the *only condition* is usually too broad, and may cause the rule to match more spans than expected.

### Resource Attribute References (`$resource[*]`)

Resource attribute references (`$resource[foo.bar]`) refers to attributes on the resource.

Since resources are effectively global metadata, using a resource attribute reference as the `key` for a matcher clause as the *only condition* will match every span and is usually not desirable. Typically, this is used in conjunction with `$span.root` to limit the match to the root span of each trace only.

### Event Attribute References (`$event[*]`)

Event attribute references (`$event[foo.bar]`) refers to attributes on a span event.

This reference is a bit special because a single span can have multiple span events, with each span event containing its own set of attributes. Therefore using an event attribute references in a rule, whether in a _matcher_ clause or in other positions, will cause that rule to be evaluated once per span event in the trace, whereas rules that do not reference event attributes are evaluated once per span.

### Special Fields

In additional to attributes OpenTelemetry nodes have some additional intrinsic fields, some of which are accessible in from the normalizer system with the following references:

* `$scope.name`, `$span.name`, `$event.name` – name of the instrumentation scope, span or event, respectively
* `$span.root` – `true` if the matched span is the root span in a trace, `false` otherwise

### Regex Matches

As discussed in the section on regular expressions, the following references can be used to access match data from the most recent regex match in the same rule. When there is no match, all of these references will have the value `null`.

* `$match[0]` – the entire match
* `$match[*]` – the corresponding capture group (either a numeric index or the name of a named capture group)

### `$null` reference

The special `$null` reference provides a way to express the `null` value in the TOML syntax.

<!-- TODO: env and config -->

## Expressions

So far, we have mostly been working with literals and references. These are examples of _expressions_. Generally speaking, expressions can be used interchangeably in most positions. For example, we have seen these in the assignment positions, but they work in value matchers as well:

```toml
[[rules]]
# Instead of comparing a reference against a literal, we can also compare it
# with the value from another reference:
match = { key = "$span[foo.bar]", value.eq = "$span[bar.baz]" }

[[rules]]
# Or even the value of an interpolated string:
match = { key = "$span[foo.bar]", value.eq = "{$span[foo]} - {$span[bar]}" }
```

That being said, not all positions will accept _every_ expression. For example, `match.key` requires a reference, and `match.value.matches.regex` requires a regular expression literal.

Beyond literals and references, other expressions generally have the following TOML syntax:

```toml
# As a table with named arguments
{ expression_name = { ... } }

# As an array with positional arguments
{ expression_name = [ ... ] }
```

An expression is a TOML table with a single key – the name of the expression. The value of this key is its arguments – either as named arguments with another TOML table, or as positional arguments with a TOML array. We provide the latter as an option for all expressions due to TOML's current limitation that inline tables must fit on a single line, whereas arrays do not have that restriction.

Like literals and references, they can be used in many positions, but most commonly in assignments.

### Expression: `replace`

The `replace` expression can be used to search within a string for matches against a regex, and replace occurrences of the matches with a replacement string:

```toml
# replace(regex, source, with)

[[rules]]
match = { key = "$span[foo.bar]", value.is.string = true }

"$span[foo.bar]".replace = [
  # Regex to search for
  "(?i)secret",
  # The source string to search in
  "$span[foo.bar]",
  # The substitution/replacement string
  "*redacted*",
]

# Equivalently, with named arguments

[[rules]]
match = { key = "$span[foo.bar]", value.is.string = true }

"$span[foo.bar]".replace.regex = "(?i)secret"
"$span[foo.bar]".replace.source = "$span[foo.bar]"
"$span[foo.bar]".replace.with = "*redacted*"
```

The replacement string can be interpolated with the `$match[*]` references to access the capture groups. If there are multiple occurrences of the matches within the source string, the `$match[*]` references will be re-evaluated on each occurrence, potentially yielding different values on each substitution.

By default, a `replace` expression has no limit on the number of matches, but an optional forth argument (or the named argument `limit`) can impose a limit on the number of matches:

```toml
# replace(regex, source, with, limit?)

[[rules]]
match = { key = "$span[foo.bar]", value.is.string = true }

"$span[foo.bar]".replace = [
  "(?i)secret",
  "$span[foo.bar]",
  "*redacted*",
  # Only replace the first occurrence
  1
]

# Equivalently, with named arguments

[[rules]]
match = { key = "$span[foo.bar]", value.is.string = true }

"$span[foo.bar]".replace.regex = "(?i)secret"
"$span[foo.bar]".replace.source = "$span[foo.bar]"
"$span[foo.bar]".replace.with = "*redacted*"
"$span[foo.bar]".replace.limit = 1
```

<!-- TODO Execution Model -->

<!-- TODO Use Cases -->

[otel-semconv]: https://opentelemetry.io/docs/specs/semconv/
[toml]: https://toml.io/en/
[toml-spec]: https://toml.io/en/v1.0.0
[toml-integers]: https://toml.io/en/v1.0.0#integer
[toml-floats]: https://toml.io/en/v1.0.0#float
[toml-strings]: https://toml.io/en/v1.0.0#string
[toml-multiline-tables]: https://github.com/toml-lang/toml/pull/904
[semver]: https://semver.org/
