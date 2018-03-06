# ExL7

Elixir HL7 quick parsing, mapping, and manipulation library.

## Examples

### Parsing

    hl7 =
      "MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\r" <>
        "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby|||||20000119\r" <>
        "OBR|20160315224533|20160124040433+0600\r" <>
        "OBX|1|doc^ricky|diagnosis^flu\r" <>
        "OBX|2|doc^bobby|diganosis^cold"

    {:ok, e_message} = ExL7.parse(hl7)

### Basic Queries

    "ExL7" = ExL7.query(e_message, "MSH|2")
    "R01" = ExL7.query(e_message, "MSH|8^1")
    ["doc^ricky", "doc^bobby"] = ExL7.query(e_message, "OBX[2]")
    ["flu", "cold"] = ExL7.query(e_message, "OBX|3[1]")

    # Matching specific field from a list of repetitions
    "999" = ExL7.query(e_message, "PID|2(0,RefDoc)^1")
    "Bob" = ExL7.query(e_message, "PID|2(0,AttDoc)^2&1")

### Date Queries

Date queries will convert a given date into a UTC timestamp unless otherwise specified.

#### DateTime Parsing

    "20000119" = ExL7.query(e_message, "PID|7")
    "2000-01-19 00:00:00" = ExL7.query(e_message, "@PID|7")

    "20160315224533" = ExL7.query(e_message, "OBR|1")
    "2016-03-15 22:45:33" = ExL7.query(e_message, "@OBR|1")

    # Offset converted to UTC is a day earlier
    "20160124040433+0600" = ExL7.query(e_message, "OBR|2")
    "2016-01-23 22:04:33" = ExL7.query(e_message, "@OBR|2")

#### DateTime Timezones

    "20000119" = ExL7.query(e_message, "PID|7", %ExL7.Query.DateOptions{timezone: "America/Chicago"})
    "2000-01-19 06:00:00" = ExL7.query(e_message, "@PID|7", %ExL7.Query.DateOptions{timezone: "America/Chicago"})
    "2000-01-18 13:00:00" = ExL7.query(e_message, "@PID|7", %ExL7.Query.DateOptions{timezone: "Australia/Sydney"})

    "20160315224533" = ExL7.query(e_message, "OBR|1")
    "2016-03-15 22:45:33" = ExL7.query(e_message, "@OBR|1")
    "2016-03-16 03:45:33" = ExL7.query(e_message, "@OBR|1", %ExL7.Query.DateOptions{timezone: "America/Chicago"})
    "2016-03-15 22:45:33" = ExL7.query(e_message, "@OBR|1", %ExL7.Query.DateOptions{timezone: "America/Chicago", ignore_timezone: true})

    # Offset converted to UTC is a day earlier
    "20160124040433+0600" = ExL7.query(e_message, "OBR|2")
    "2016-01-23 22:04:33" = ExL7.query(e_message, "@OBR|2")

    # DateTimes with an offset ignore the timezone property
    "2016-01-23 22:04:33" = ExL7.query(e_message, "@OBR|2", %ExL7.Query.DateOptions{timezone: "America/Chicago"})
    "2016-01-23 22:04:33" = ExL7.query(e_message, "@OBR|2", %ExL7.Query.DateOptions{timezone: "Australia/Sydney"})

    # Ignore the timezone offset
    "2016-01-24 04:04:33" = ExL7.query(e_message, "@OBR|2", %ExL7.Query.DateOptions{ignore_timezone: true})

#### DateTime Formatting

    "2000-01-19" = ExL7.query(e_message, "@PID|7", %ExL7.Query.DateOptions{format: "{YYYY}-{0M}-{0D}"})
    "2000-01-19 000000" = ExL7.query(e_message, "@PID|7", %ExL7.Query.DateOptions{format: "{YYYY}-{0M}-{0D} {h24}{m}{s}"})

    "20160315" = ExL7.query(e_message, "@OBR|1", %ExL7.Query.DateOptions{format: "{YYYY}{0M}{0D}"})
    "2016-03-15" = ExL7.query(e_message, "@OBR|1", %ExL7.Query.DateOptions{format: "{YYYY}-{0M}-{0D}"})

### String Functions

    # Return the original message
    "MSH|^....." = ExL7.Message.to_string(e_message)

### Acknowledgement

    # Start a Sequence Agent to generate sequences (or use your own custom sequences)
    {:ok, sequence_pid} = ExL7.Ack.Sequence.start_link()
    sequence_id = ExL7.Ack.Sequence.get_next(sequence_pid)

    ExL7.Ack.acknowledge(e_message, sequence_id)

    ack_config = %ExL7.Ack.Config{}

    # App Error Responses
    ExL7.Ack.error(ack_config, sequence_id)
    ExL7.Ack.error(ack_config, sequence_id, "server down")

    ExL7.Ack.default_error(sequence_id)
    ExL7.Ack.default_error(sequence_id, "server down")

    # App Rejection Responses
    ExL7.Ack.reject(ack_config, sequence_id)
    ExL7.Ack.reject(ack_config, sequence_id, "bad msh")

    ExL7.Ack.default_reject(sequence_id)
    ExL7.Ack.default_reject(sequence_id, "bad msh")

    # Custom Responses
    ExL7.Ack.other(ack_config, sequence_id, "OT")
    ExL7.Ack.other(ack_config, sequence_id, "OT", "other reason")

## Versioning

Use [SemVer](http://semver.org/) for versioning. Still in development.

## Acknowledgements

- [medic/L7](https://github.com/medic/L7)
- [iWT Health](https://www.iwthealth.com/)
