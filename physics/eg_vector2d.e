note
	description: "Objects that is a two dimensional vector."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	author: "Benno Baumgartner"
	date: "$Date$"
	revision: "$Revision$"

class
	EG_VECTOR2D [G -> NUMERIC]

inherit
	EG_VECTOR [G]
		redefine
			default_create
		end

create
	default_create,
	make

feature {NONE} -- Initialization

	default_create
		obsolete
			"`default_create' is not void-safe statically. Use `make' instead. [02-2014]"
		do
			make (({G}).default, ({G}).default)
		ensure then
			set: x = ({G}).default and y = ({G}).default
		end

	make (a_x: like x; a_y: like y)
			-- Set `x' to `a_x' and `y' to `a_y'.
		do
			x := a_x
			y := a_y
		ensure
			set: x = a_x and y = a_y
		end

feature -- Element change

	set (a_x: like x; a_y: like y)
			-- Set `x' to `a_x' and `y' to `a_y'.
		obsolete
			"Create a new instance with `make' creation procedure since EG_VECTOR2D is immutable. [03-2014]"
		do
			make (a_x, a_y)
		ensure
			set: x = a_x and y = a_y
		end

feature -- Access

	x: G
			-- X position.

	y: G
			-- Y position.

	attached_x: G
			-- `x'.
		obsolete
			"use `x' instead. [02-2014]"
		do
			Result := x
		end

	attached_y: G
			-- `y'.
		obsolete
			"use `y' instead. [02-2014]"
		do
			Result := y
		end

	one: like Current
			-- <Precursor>
		do
			create Result.make (x.one, y.one)
		end

	zero: like Current
			-- <Precursor>
		do
			create Result.make (x.zero, y.zero)
		end

feature -- Status report

	divisible (other: like Current): BOOLEAN
			-- <Precursor>
		do
			Result := False
		end

	exponentiable (other: NUMERIC): BOOLEAN
			-- <Precursor>
		do
			Result := True
		end

	is_x_y_set: BOOLEAN
			-- If `x' and `y' has been set?
		obsolete
			"Answer is True since `x' and `y' are both attached. [02-2014]"
		once
			Result := True
		end

feature -- Basic operations

	plus alias "+" (other: like Current): like Current
			-- <Precursor>
		do
			create Result.make (x + other.x, y + other.y)
		end

	minus alias "-" (other: like Current): like Current
			-- <Precursor>
		do
			create Result.make (x - other.x, y - other.y)
		end

	scalar_product alias "*" (other: like Current): like Current
			-- <Precursor>
		do
			create Result.make (x * other.x, y * other.y)
		ensure then
			definition: Result.x = x * other.x and Result.y = y * other.y
		end

	quotient alias "/" (other: like Current): like Current
			-- <Precursor>
		do
			check vectors_are_divisible: False then end
		end

	identity alias "+": like Current
			-- <Precursor>
		do
			create Result.make (x, y)
		end

	opposite alias "-": like Current
			-- <Precursor>
		do
			create Result.make (-x, -y)
		end

	product alias "|*" (a_value: G): like Current
			-- <Precursor>
		do
			create Result.make (x * a_value, y * a_value)
		ensure then
			definition: Result.x = x * a_value and Result.y = y * a_value
		end

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




end -- class EG_VECTOR2D

