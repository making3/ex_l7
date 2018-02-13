# ExL7

Elixir HL7 quick parsing, mapping, and manipulation library.

## Examples

### Parsing

    hl7 =
      "MSH|^~\\&|ExL7|iWT Health||1|||ORU^R01||T|2.4\r" <>
        "PID|123^MR~456^AN|AttDoc^888^Ross&Bob~RefDoc^999^Hill&Bobby\r" <>
        "OBX|1|doc^ricky|diagnosis^flu\r" <>
        "OBX|2|doc^bobby|diganosis^cold"

    {:ok, e_message} = ExL7.parse(hl7)

    # Basic Queries
    "ExL7" = ExL7.query(e_message, "MSH|2")
    "R01" = ExL7.query(e_message, "MSH|8^1")
    ["doc^ricky", "doc^bobby"] = ExL7.query(e_message, "OBX[2]")
    ["flu", "cold"] = ExL7.query(e_message, "OBX|3[1]")

    # Custom component match selectors
    "999" = ExL7.query(e_message, "PID|2(0,RefDoc)^1")
    "Bob" = ExL7.query(e_message, "PID|2(0,AttDoc)^2&1")

    # To return the original message
    "MSH|^....." = ExL7.Message.to_string(e_message)

### Acknowledgement

    # Start a Sequence Agent to generate sequences (or use your own custom sequences)
    sequencer = ExL7.Ack.Sequence.start_link()
    sequence_id = ExL7.get_next(sequencer)

    ExL7.Ack.acknowledge(e_message, sequence_id)

    ack_config = %ExL7.Config.Ack{}

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
    ExL7.Ack.other("AZ", sequence_id)
    ExL7.Ack.other("AZ", sequence_id, "other reason")

## Versioning

Use [SemVer](http://semver.org/) for versioning. Still in development.

## Acknowledgements

- [medic/L7](https://github.com/medic/L7)
- [iWT Health](https://www.iwthealth.com/)
