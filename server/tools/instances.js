// Instance tree, search, lifecycle, properties, attributes, tags, reflection
import { z, target, optTarget, value, nameMode, ci, limit, offset, depth, maxItems, maxStr, args, serOpts } from "./common.js";

const treeText = (r) => `${r.tree}\n-- ${r.nodes} node(s) shown${r.truncated ? " (truncated: raise max_nodes or lower depth)" : ""}`;

export function register({ tool }) {
	// ---------------------------------------------------------------- navigation
	tool(
		"get_children",
		"List the direct children of an instance (default: game). Each child has class, name, ref, child count and a small value preview (ValueBase value, part position, GUI text, script disabled).",
		{
			target: optTarget,
			class: z.string().optional().describe("Only children that IsA this class."),
			name: z.string().optional().describe("Only children whose name matches."),
			name_mode: nameMode,
			case_insensitive: ci,
			offset,
			limit: limit(200),
			counts: z.boolean().optional().describe("Include grandchild counts (default true when <=300 children)."),
		},
	);

	tool(
		"get_descendants",
		"List descendants of an instance filtered by class/name, with paths. Use find_instances for property/attribute/tag filters.",
		{
			target: optTarget,
			class: z.string().optional().describe("IsA filter (or exact ClassName with class_exact)."),
			class_exact: z.boolean().optional(),
			name: z.string().optional(),
			name_mode: nameMode,
			case_insensitive: ci,
			max_depth: z.number().int().positive().optional().describe("Limit traversal depth (1 = children only)."),
			offset,
			limit: limit(200),
		},
	);

	tool(
		"get_tree",
		"Render an indented tree of the hierarchy under an instance (default game), like the Dex Explorer. Cheapest way to understand a game's layout.",
		{
			target: optTarget,
			depth: z.number().int().positive().optional().describe("Levels to expand (default 3)."),
			max_nodes: z.number().int().positive().optional().describe("Stop after this many nodes (default 400)."),
			refs: z.boolean().optional().describe("Append #ref ids to each line."),
			class: z.string().optional().describe("Only show nodes of this class (and their ancestors)."),
		},
		{ format: treeText },
	);

	tool(
		"find_instances",
		"Search the hierarchy: by name, class, tag, attribute, property value, visible text, or child presence. Optionally includes nil-parented instances. Returns paths and refs.",
		{
			root: optTarget.describe("Subtree to search (default game)."),
			class: z.string().optional(),
			class_exact: z.boolean().optional(),
			name: z.string().optional(),
			name_mode: nameMode,
			case_insensitive: ci,
			tag: z.string().optional().describe("CollectionService tag."),
			attribute: z.object({ name: z.string(), value: z.any().optional() }).optional().describe("Attribute that must exist (and equal value, compared as text)."),
			property: z.object({ name: z.string(), value: z.any().optional(), mode: nameMode }).optional().describe("Property that must equal value (strings matched per mode)."),
			text: z.string().optional().describe("Match the Text property (TextLabel/TextButton/TextBox)."),
			text_mode: nameMode,
			has_children: z.boolean().optional(),
			max_depth: z.number().int().positive().optional(),
			include_self: z.boolean().optional(),
			include_nil: z.boolean().optional().describe("Also scan nil-parented instances (needs getnilinstances)."),
			deep_nil: z.boolean().optional().describe("With include_nil, also scan their descendants."),
			stop_at_limit: z.boolean().optional().describe("Stop scanning once limit results are found (faster, but matched is then a lower bound)."),
			limit: limit(100),
		},
	);

	tool(
		"get_instance",
		"Full summary of one instance: class chain, paths, parent, children, attributes, tags, debug id, key values.",
		{
			target,
			count_descendants: z.boolean().optional(),
			children: z.boolean().optional().describe("Include a child list (default true)."),
			max_children: z.number().int().positive().optional(),
		},
	);

	tool(
		"get_path",
		"Get the Lua path expression for an instance (Dex Explorer 'Copy Path' style) plus an unambiguous :GetChildren()[i] index path.",
		{ target, style: z.enum(["dex", "simple"]).optional() },
	);

	tool("resolve_path", "Resolve a path expression to an instance (returns ref and class) or explain where resolution failed.", { path: z.string() });

	tool("get_ancestors", "List the ancestor chain of an instance, nearest first.", { target });

	tool("get_services", "List all services currently under game with child counts.", {});

	tool(
		"get_nil_instances",
		"List nil-parented instances (needs getnilinstances): scripts/modules/GUIs the game removed from the tree but still holds.",
		{ class: z.string().optional(), class_exact: z.boolean().optional(), name: z.string().optional(), name_mode: nameMode, case_insensitive: ci, offset, limit: limit(200) },
	);

	tool(
		"get_all_instances",
		"Every instance the executor can see (getinstances), including nil-parented and hidden ones. Filter by class/name; set nil_only for the unparented ones.",
		{ class: z.string().optional(), class_exact: z.boolean().optional(), name: z.string().optional(), name_mode: nameMode, case_insensitive: ci, nil_only: z.boolean().optional(), offset, limit: limit(200) },
	);

	tool(
		"debug_id",
		"Debug ids are stable identifiers for an instance. action=get returns the id of target; action=find locates an instance by debug id.",
		{ action: z.enum(["get", "find"]), target: optTarget, debug_id: z.string().optional() },
		{
			route: (a) => (a.action === "get" ? { cmd: "get_debug_id", params: { target: a.target } } : { cmd: "find_by_debug_id", params: { debug_id: a.debug_id } }),
			ro: true,
		},
	);

	tool("compare_instances", "Check whether two references point to the same instance (uses compareinstances so cloneref'd copies compare equal).", { a: target, b: target });

	tool(
		"get_instance_signals",
		"List an instance's events (from the API dump) with how many connections each has. Shows what game code is listening to.",
		{ target, all: z.boolean().optional().describe("Include events with zero connections.") },
	);

	// ---------------------------------------------------------------- lifecycle
	tool(
		"create_instance",
		"Create an instance (Instance.new) with optional name, properties and parent.",
		{ class: z.string(), name: z.string().optional(), props: z.record(z.string(), z.any()).optional().describe("Property name -> value (see value format)."), parent: optTarget },
	);

	tool("clone_instance", "Clone an instance (Archivable is toggled temporarily if needed), optionally renaming and parenting the clone.", { target, name: z.string().optional(), parent: optTarget });

	tool(
		"destroy_instance",
		"Destroy an instance (or only its children with clear_children). Irreversible within the session.",
		{ target, clear_children: z.boolean().optional() },
		{ destructive: true },
	);

	tool("set_parent", "Reparent an instance. Pass parent=null to make it nil-parented.", { target, parent: z.union([z.string(), z.number(), z.null()]).optional() });

	// ---------------------------------------------------------------- properties
	tool(
		"get_properties",
		"All properties of an instance read via the Roblox API dump (typed, categorised, with read/write security and tags), plus attributes and tags. Hidden/not-scriptable props are read with gethiddenproperty when include_hidden is set.",
		{
			target,
			name: z.string().optional().describe("Filter property names."),
			name_mode: nameMode,
			category: z.string().optional().describe('Filter by category, e.g. "Data", "Behavior", "Appearance".'),
			include_hidden: z.boolean().optional().describe("Include NotScriptable properties (via gethiddenproperty)."),
			include_deprecated: z.boolean().optional(),
			only_non_default: z.boolean().optional().describe("Only properties that differ from a freshly created instance of the class."),
			include_attributes: z.boolean().optional(),
			...serOpts,
		},
	);

	tool("get_property", "Read one property (including hidden ones) with deeper serialization than get_properties.", { target, name: z.string(), ...serOpts });

	tool(
		"get_properties_bulk",
		"Read the same list of properties from many instances at once (compact table of values).",
		{ targets: z.array(z.union([z.string(), z.number()])).describe("Instances (paths or refs)."), properties: z.array(z.string()) },
	);

	tool(
		"set_property",
		"Write one property (name+value) or several (properties map). Values are coerced using the API type: Vector3 [1,2,3], Color3 \"#ff0000\", enums by name, Instances by path. Falls back to sethiddenproperty.",
		{ target, name: z.string().optional(), value: value.optional(), properties: z.record(z.string(), z.any()).optional().describe("Alternative: {propertyName: value, ...}") },
		{ route: (a) => (a.properties ? { cmd: "set_properties", params: { target: a.target, properties: a.properties } } : { cmd: "set_property", params: { target: a.target, name: a.name, value: a.value } }) },
	);

	tool(
		"compare_properties",
		"Diff two instances: every property and attribute that differs (Name/Parent ignored by default), plus how many matched. Great for 'what makes this door different from that one?'.",
		{ a: target, b: target, ignore: z.array(z.string()).optional().describe("Extra property names to skip."), ignore_identity: z.boolean().optional().describe("Skip Name/Parent (default true)."), include_hidden: z.boolean().optional() },
		{ ro: true },
	);

	tool("set_property_many","Set the same property on many instances.", { targets: z.array(z.union([z.string(), z.number()])), name: z.string(), value });

	tool(
		"hidden_property",
		"Read or write a hidden/not-scriptable property with gethiddenproperty/sethiddenproperty (e.g. NetworkOwnerV3, size_xml).",
		{ action: z.enum(["get", "set"]), target, name: z.string(), value: value.optional() },
		{ route: (a) => (a.action === "get" ? { cmd: "get_hidden_property", params: { target: a.target, name: a.name } } : { cmd: "set_hidden_property", params: { target: a.target, name: a.name, value: a.value } }), ro: false },
	);

	tool(
		"scriptable",
		"Check (action=is) or change (action=set) whether a property is scriptable via isscriptable/setscriptable.",
		{ action: z.enum(["is", "set"]), target, name: z.string(), value: z.boolean().optional().describe("For set: true to make scriptable (default).") },
		{ route: (a) => (a.action === "is" ? { cmd: "is_scriptable", params: { target: a.target, name: a.name } } : { cmd: "set_scriptable", params: { target: a.target, name: a.name, value: a.value } }) },
	);

	tool(
		"attributes",
		"Get all attributes (action=get), set one (action=set name+value) or delete one (action=delete).",
		{ action: z.enum(["get", "set", "delete"]), target, name: z.string().optional(), value: value.optional() },
		{ route: (a) => ({ cmd: { get: "get_attributes", set: "set_attribute", delete: "delete_attribute" }[a.action], params: { target: a.target, name: a.name, value: a.value } }) },
	);

	tool(
		"tags",
		"CollectionService tags: action=get (tags of target), add/remove (target+tag), find (all instances with tag), list (all tags in the game).",
		{ action: z.enum(["get", "add", "remove", "find", "list"]), target: optTarget, tag: z.string().optional(), limit: limit(200) },
		{ route: (a) => ({ cmd: { get: "get_tags", add: "add_tag", remove: "remove_tag", find: "find_by_tag", list: "list_tags" }[a.action], params: { target: a.target, tag: a.tag, limit: a.limit } }) },
	);

	tool(
		"call_method",
		"Call a method on an instance (e.g. GetChildren, FindFirstChild, IsA, Clone, GetFullName, FireServer...) and serialize the results.",
		{ target, method: z.string(), args, ...serOpts },
	);

	// ---------------------------------------------------------------- reflection
	tool(
		"get_class_info",
		"Reflect a Roblox class from the API dump: superclass chain, tags, and every property/function/event with types and security levels.",
		{ class: z.string(), members: z.boolean().optional().describe("Include member lists (default true).") },
	);

	tool("list_classes", "List Roblox classes from the API dump, optionally filtered by substring or by superclass.", { filter: z.string().optional(), subclass_of: z.string().optional(), limit: limit(300) });

	tool(
		"enums",
		"Roblox enums: action=list (names, optionally filtered) or action=get (all items and values of one enum).",
		{ action: z.enum(["list", "get"]), name: z.string().optional().describe("Enum name for action=get."), filter: z.string().optional() },
		{ route: (a) => (a.action === "get" ? { cmd: "get_enum", params: { name: a.name } } : { cmd: "list_enums", params: { filter: a.filter } }) },
	);
}
