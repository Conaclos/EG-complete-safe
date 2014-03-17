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
			-- X position

	y: G
			-- Y position

	attached_x: G
			-- `x'
		obsolete
			"use `x' instead. [02-2014]"
		do
			Result := x
		end

	attached_y: G
			-- `y'
		obsolete
			"use `y' instead. [02-2014]"
		do
			Result := y
		end

	one: like Current
			-- Neutral element for "*" and "/"
		do
			create Result.make (x.one, y.one)
		end

	zero: like Current
			-- Neutral element for "+" and "-"
		do
			create Result.make (x.zero, y.zero)
		end

feature -- Status report

	divisible (other: like Current): BOOLEAN
			-- May current object be divided by `other'?
		do
			Result := False
		end

	exponentiable (other: NUMERIC): BOOLEAN
			-- May current object be elevated to the power `other'?
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
			-- Sum with `other' (commutative)
		do
			create Result.make (x + other.x, y + other.y)
		end

	minus alias "-" (other: like Current): like Current
			-- Result of subtracting `other'
		do
			create Result.make (x - other.x, y - other.y)
		end

	product alias "*" (other: like Current): like Current
			-- Product by `other'
		do
			check False then end
		end

	quotient alias "/" (other: like Current): like Current
			-- Division by `other'
		do
			check False then end
		end

	identity alias "+": like Current
			-- Unary plus
		do
			create Result.make (x, y)
		end

	opposite alias "-": like Current
			-- Unary minus
		do
			create Result.make (-x, -y)
		end

	scalar_product alias "|*" (other: G): like Current
			-- Scalar product between `Current' and other.
		do
			create Result.make (x * other, y * other)
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

