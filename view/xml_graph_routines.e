note
	description: "[
			Common routines for XML extraction, saving and deserialization
		]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	XML_GRAPH_ROUTINES

inherit
	EXCEPTIONS
    	rename
    		tag_name as exceptions_tag_name,
    		class_name as exceptions_class_names
    	redefine
    		default_create
    	end

inherit {NONE}
	XML_CALLBACKS_FILTER_FACTORY
		export
			{NONE} all
		redefine
			default_create
		end

create {EG_XML_STORABLE}
	default_create,
	make

feature {NONE} -- Initialization

	default_create
			-- Create an XML_ROUTINE.
		do
			create valid_tag_read_actions
		end

	make (a_relative_window: attached like relative_window)
			-- Initialization.
		require
			non_void_relative_window: a_relative_window /= Void
		do
			default_create
			relative_window := a_relative_window
		ensure
			relative_window_set : relative_window = a_relative_window
		end

feature {NONE} -- Access

	relative_window: detachable EV_WINDOW
			-- relative window.
		note
			option: stable
		attribute end

feature {EG_XML_STORABLE} -- Access

	number_of_tags (a_node: like xml_node): INTEGER
			-- Number of tags in node and all childrens of node.
		require
			a_node_not_void: a_node /= Void
		do
			across
				a_node as it
			loop
				if attached {like xml_node} it.item as l_item then
					Result := Result + number_of_tags (l_item)
				elseif attached {XML_ATTRIBUTE} it.item then
					Result := Result + 1
				end
			end
		end

feature {EG_XML_STORABLE} -- Status report

	valid_tags: INTEGER
			-- Number of valid tags read.

	valid_tag_read_actions: EV_NOTIFY_ACTION_SEQUENCE
			-- Event triggered when a tag was just readed.

feature {EG_XML_STORABLE} -- Status setting

	reset_valid_tags
			-- Reset `valid_tags'.
		do
			valid_tags := 0
		ensure
			valid_tags_is_nul: valid_tags = 0
		end

	valid_tags_read
			-- A valid tag was just read.
		do
			valid_tags := valid_tags + 1
			valid_tag_read_actions.call (Void)
		ensure
			valid_tags_incremented: valid_tags = old valid_tags + 1
		end

feature {EG_XML_STORABLE} -- Processing

	xml_integer (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): INTEGER
			-- Find in sub-elememt of `a_elem' integer item with tag `a_name'.
		require
			a_elem_attached: a_elem /= Void
			a_name_attached: a_name /= Void
		do
			if attached {like xml_node} a_elem.item_for_iteration as e and then e.has_same_name (a_name) then
				if attached e.text as l_text and then l_text.is_integer then
					Result := l_text.to_integer
					valid_tags_read
				else
					display_warning_message ({STRING_32} "Value of element " + a_name.to_string_32 + {STRING_32} " is not valid.")
				end
			else
				display_warning_message ({STRING_32} "Element " + a_name.to_string_32 + {STRING_32} " expected but not found.")
			end
			a_elem.forth
		end

	xml_boolean (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): BOOLEAN
			-- Find in sub-elememt of `a_elem' boolean item with tag `a_name'.
		require
			a_elem_attached: a_elem /= Void
			a_name_attached: a_name /= Void
		do
			if attached {like xml_node} a_elem.item_for_iteration as e and then e.has_same_name (a_name) then
				if attached e.text as l_text and then l_text.is_boolean then
					Result := l_text.to_boolean
					valid_tags_read
				else
					display_warning_message ({STRING_32} "Value of element " + a_name.to_string_32 + {STRING_32} " is not valid.")
				end
			else
				display_warning_message ({STRING_32} "Element " + a_name.to_string_32 + {STRING_32} " expected but not found.")
			end
			a_elem.forth
		end

	xml_double (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): REAL_64
			-- Find in sub-elememt of `a_elem' integer item with tag `a_name'.
		require
			a_elem_attached: a_elem /= Void
			a_name_attached: a_name /= Void
		do
			if attached {like xml_node} a_elem.item_for_iteration as e and then e.has_same_name (a_name) then
				if attached e.text as l_text and then l_text.is_double then
					Result := l_text.to_double
					valid_tags_read
				else
					display_warning_message ({STRING_32} "Value of element " + a_name.to_string_32 + {STRING_32} " is not valid.")
				end
			else
				display_warning_message ({STRING_32} "Element " + a_name.to_string_32 + {STRING_32} " expected but not found.")
			end
			a_elem.forth
		end

	xml_string (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): detachable STRING
			-- Find in sub-elememt of `a_elem' string item with tag `a_name'.
		require
			a_elem_attached: a_elem /= Void
			a_name_attached: a_name /= Void
		do
			if attached {like xml_node} a_elem.item_for_iteration as e and then e.has_same_name (a_name) then
				if attached e.text as l_text then
					check
						is_valid_as_string_8: l_text.is_valid_as_string_8
					end
					Result := l_text.to_string_8
				end
				valid_tags_read
			else
				display_warning_message ({STRING_32} "Element " + a_name.to_string_32 + {STRING_32} " expected but not found.")
			end
			a_elem.forth
		ensure
			Result_attached: Result /= Void
		end

	xml_string_32 (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): detachable STRING_32
			-- Find in sub-elememt of `a_elem' string item with tag `a_name'.
		require
			a_elem_attached: a_elem /= Void
			a_name_attached: a_name /= Void
		do
			if attached {like xml_node} a_elem.item_for_iteration as e and then e.has_same_name (a_name) then
				if attached e.text as l_text then
					Result := l_text
				end
				valid_tags_read
			else
				display_warning_message ({STRING_32} "Element " + a_name.to_string_32 + {STRING_32} " expected but not found.")
			end
			a_elem.forth
		end

	xml_color (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): EV_COLOR
			-- Find in sub-elememt of `a_elem' color item with tag `a_name'.
		require
			a_elem_attached: a_elem /= Void
			a_name_attached: a_name /= Void
		local
			sc1, sc2: INTEGER
			r, g, b: INTEGER
			l_rescued: BOOLEAN
		do
			if not l_rescued then
				if
					attached {like xml_node} a_elem.item_for_iteration as e and then
					e.has_same_name (a_name) and then
					attached e.text as s and then
					not s.is_empty
				then
					check
						two_semicolons: s.occurrences (';') = 2
					end
					sc1 := s.index_of (';', 1)
					r := s.substring (1, sc1 - 1).to_integer
					sc2 := s.index_of (';', sc1 + 1)
					g := s.substring (sc1 + 1, sc2 - 1).to_integer
					b := s.substring (sc2 + 1, s.count).to_integer
					create Result.make_with_8_bit_rgb (r, g, b)
					valid_tags_read
				else
					display_warning_message ({STRING_32} "Value of element " + a_name.to_string_32 + {STRING_32} " is not valid.")
					create Result.make_with_8_bit_rgb (255, 255, 0)
				end
			else
				display_warning_message ("Retrieve default color.")
					-- Default color
				create Result.make_with_8_bit_rgb (255, 255, 0)
			end
			a_elem.forth
		ensure
			non_void_color: Result /= Void
		rescue
			l_rescued := True
			retry
		end

	element_by_name (a_elem: like xml_node; a_name: READABLE_STRING_GENERAL): detachable like xml_node
			-- Find in sub-elemement of `a_elem' an element with tag `a_name'.
		require
			a_elem_not_void: a_elem /= Void
			a_name_attached: a_name /= Void
		do
			Result := a_elem.element_by_name (a_name)
		end

	xml_string_node (a_parent: like xml_node; s: READABLE_STRING_GENERAL): XML_CHARACTER_DATA
			-- New node with `s' as content.
		require
			a_parent_attached: a_parent /= Void
			s_attached: s /= Void
		do
			create Result.make (a_parent, s.to_string_32)
		ensure
			Result_attached: Result /= Void
		end

	xml_node (a_parent: like xml_node; a_tag_name, a_content: READABLE_STRING_GENERAL): XML_ELEMENT
			-- New node with `s' as content and named `tag_name'.
		require
			a_parent_attached: a_parent /= Void
			a_content_attached: a_content /= Void
			a_tag_name_attached: a_tag_name /= Void
		do
			create Result.make (a_parent, a_tag_name.to_string_32, default_namespace)
			Result.put_last (xml_string_node (Result, a_content))
		ensure
			Result_attached: Result /= Void
		end

feature -- Saving

	save_xml_document (a_file_name: READABLE_STRING_GENERAL; a_doc: XML_DOCUMENT)
			-- Save `a_doc' in `ptf'.
		require
			a_file_name_not_void: a_file_name /= Void
			file_exists: not a_file_name.is_empty
		do
			save_xml_document_with_path (create {PATH}.make_from_string (a_file_name), a_doc)
		end

	save_xml_document_with_path (a_file_name: PATH; a_doc: XML_DOCUMENT)
			-- Save `a_doc' in `ptf'.
		require
			a_file_name_not_void: a_file_name /= Void
			file_exists: not a_file_name.is_empty
		local
			l_retried: BOOLEAN
			l_formatter: XML_FORMATTER
			l_output_file: RAW_FILE
		do
			if not l_retried then
					-- Write document
				create l_output_file.make_with_path (a_file_name)
				if not l_output_file.exists or else l_output_file.is_writable then
					l_output_file.open_write
					create l_formatter.make
					l_formatter.set_output_file (l_output_file)
					l_formatter.process_document (a_doc)
					l_output_file.flush
					l_output_file.close
				else
					display_error_message ({STRING_32} "Unable to write file: " + a_file_name.name)
				end
			end
		rescue
			l_retried := True
			display_error_message ({STRING_32} "Unable to write file: " + a_file_name.name)
			retry
		end

feature -- Deserialization

	deserialize_document (a_file_path: READABLE_STRING_GENERAL): detachable XML_DOCUMENT
			-- Retrieve xml document associated to file
			-- serialized in `a_file_path'.
			-- If deserialization fails, return Void.
		require
			a_file_path_attached: a_file_path /= Void
			valid_file_path: not a_file_path.is_empty
		do
			Result := deserialize_document_with_path (create {PATH}.make_from_string (a_file_path))
		end

	deserialize_document_with_path (a_file_path: PATH): detachable XML_DOCUMENT
			-- Retrieve xml document associated to file
			-- serialized in `a_file_path'.
			-- If deserialization fails, return Void.
		require
			a_file_path_attached: a_file_path /= Void
			valid_file_path: not a_file_path.is_empty
		local
			l_parser: XML_STOPPABLE_PARSER
			l_tree: XML_CALLBACKS_NULL_FILTER_DOCUMENT
			l_file: PLAIN_TEXT_FILE
			l_xm_concatenator: XML_CONTENT_CONCATENATOR
		do
			create l_file.make_with_path (a_file_path)
			if l_file.exists and l_file.is_readable then
				l_file.open_read
				check is_open_read: l_file.is_open_read end
				create l_parser.make
				create l_tree.make_null
				create l_xm_concatenator.make_null
				l_parser.set_callbacks (standard_callbacks_pipe (<<l_xm_concatenator, l_tree>>))
				l_parser.parse_from_file (l_file)
				l_file.close
				if l_parser.is_correct then
					Result := l_tree.document
				else
					display_error_message ({STRING_32} "File " + a_file_path.name + {STRING_32} " is corrupted")
					Result := Void
				end
			else
				display_error_message ({STRING_32} "File " + a_file_path.name + {STRING_32} " cannot not be open")
			end
		end

feature {NONE} -- Implementation

	default_namespace: XML_NAMESPACE
			-- Default namespace for nodes.
		once
			create Result.make_default
		ensure
			Result_attached: Result /= Void
		end

feature {NONE} -- Error management

	display_warning_message (a_warning_msg: READABLE_STRING_GENERAL)
			-- Display `a_warning_msg' in a warning popup window.
		require
			a_warning_msg_attached: a_warning_msg /= Void
			valid_error_message: not a_warning_msg.is_empty
		local
			l_warning_window: EV_WARNING_DIALOG
		do
			create l_warning_window.make_with_text (a_warning_msg)
			l_warning_window.show
		end

	display_error_message (a_error_msg: READABLE_STRING_GENERAL)
			-- Display `an_error_msg' in an error popup window.
		require
			a_error_msg_attached: a_error_msg /= Void
			valid_error_message: not a_error_msg.is_empty
		local
			l_error_window: EV_ERROR_DIALOG
		do
			create l_error_window.make_with_text (a_error_msg)
			l_error_window.show
		end

	display_warning_message_relative (a_warning_msg: READABLE_STRING_GENERAL; a_parent_window: EV_WINDOW)
			-- Display `a_warning_msg' in a warning popup window.
		require
			non_void_parent_window: a_parent_window /= Void
			a_warning_msg_attached: a_warning_msg /= Void
			valid_error_message: not a_warning_msg.is_empty
		local
			l_warning_window: EV_WARNING_DIALOG
		do
			create l_warning_window.make_with_text (a_warning_msg)
			l_warning_window.show_modal_to_window (a_parent_window)
		end

invariant
	valid_tag_read_actions_attached: valid_tag_read_actions /= Void
	valid_tags_not_negative: valid_tags >= 0

note
	copyright:	"Copyright (c) 1984-2014, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"




end -- class XML_ROUTINESOUTINES

