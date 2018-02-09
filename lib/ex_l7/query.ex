defmodule ExL7.Query do
  defstruct all_segments: false,
            segment: "",
            repeat: -1,
            field: 0,
            component: -1,
            component_match: %ExL7.Query.ComponentMatch{},
            sub_component: -1,
            is_date: false,
            default_time: false
end
