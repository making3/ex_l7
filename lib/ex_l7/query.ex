defmodule ExL7.Query do
  defstruct all_segments: false,
            segment: "",
            repeat: -1,
            field: 0,
            component: 0,
            component_match: %ExL7.Query.ComponentMatch{},
            sub_component: 0,
            is_date: false,
            default_time: false
end
