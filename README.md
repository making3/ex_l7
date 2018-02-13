# ExL7

Elixir HL7 quick parsing, mapping, and manipulation library.

## Examples

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

## Versioning

Use [SemVer](http://semver.org/) for versioning. Still in development.

## License

TODO

## Acknowledgements

- [medic/L7](https://github.com/medic/L7)
- [iWT Health](https://www.iwthealth.com/)
