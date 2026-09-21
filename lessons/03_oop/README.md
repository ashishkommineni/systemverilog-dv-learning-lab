# 03 — Object-oriented programming

## Learning objective

Use classes to model verification data and behavior while avoiding handle aliasing and accidental type loss.

## What

A class variable is a handle, not the object itself. new constructs an object and returns a handle to it.

~~~systemverilog
packet p;       // null handle
p = new();      // constructed object
~~~

Core OOP features used in verification are:

- encapsulation with local and protected members;
- constructors and methods;
- inheritance through extends;
- virtual methods and runtime polymorphism;
- static properties shared by all objects of a class;
- parameterized classes for type- or width-reusable utilities.

## Why

Transactions naturally group data with operations such as copy, compare, print, and pack. Inheritance lets a generic monitor publish a base transaction while a specialized protocol transaction adds fields. Runtime polymorphism allows the receiver to call the correct overridden method without hard-coding every subtype.

The important catch is that assignment copies a handle. It does not copy the object.

~~~systemverilog
alias = original;
alias.payload[0] = '1; // original changed too
~~~

That is useful when two components intentionally share one object, but dangerous when a scoreboard expects a stable snapshot.

## How

### Handle and object

The handle may be null, may point to an object, or may point to the same object as another handle. Check for null before dereferencing when construction is not guaranteed.

### Inheritance and polymorphism

A derived object can be assigned to a base handle. If a method is virtual, the implementation is chosen from the actual object type at runtime.

~~~systemverilog
base_handle = derived_object;
$display("%s", base_handle.describe());
~~~

If describe is virtual, the derived implementation runs.

### Encapsulation

- local: only the declaring class can access it.
- protected: the declaring class and derived classes can access it.
- unqualified members are public.

Use methods to protect invariants rather than letting every component edit internal state.

### Copy depth

A shallow copy duplicates top-level fields but keeps handles to nested objects or arrays shared. A deep copy recursively creates independent nested storage. Verification transactions commonly need deep-copy behavior before a producer reuses the original object.

### Casting

$cast(destination, source) performs a checked runtime cast and returns success. Use it when a base handle may refer to a derived object. Do not rely on an unchecked assignment that the type system rejects.

## Where

- transaction and sequence-item models;
- reusable scoreboards and predictors;
- callbacks and policy objects;
- configuration containers;
- factory-style construction.

## Code walkthrough

oop_demo creates a derived write transaction and stores it in a base handle. A virtual describe call proves dynamic dispatch. Then:

1. alias receives the base handle;
2. changing alias.payload changes the original object;
3. deep_copy creates new payload storage;
4. changing the copy no longer changes the original;
5. the static creation count proves how many objects were constructed.

## Common mistakes

- Declaring a class handle and using it before new.
- Believing handle assignment performs a field-by-field copy.
- Forgetting virtual on a method intended for polymorphic override.
- Hiding a base method with a different signature instead of overriding it.
- Copying a class that contains nested handles without defining copy ownership.

## Quick interview answer

**What is the difference between an object and a handle?**  
The object is allocated class storage. The handle is a reference that points to that storage. Assigning one handle to another makes both point to the same object; it does not construct a second object. A separate object requires new and, when needed, an explicit deep copy.

## Follow-up questions

1. What happens when the last handle to an object is lost?  
   It becomes eligible for simulator garbage collection.

2. Why make a method virtual?  
   So a call through a base handle dispatches to the actual derived object's implementation.

3. Can a static property be accessed without an object?  
   Yes, through class scope, for example transaction::created.
