# Scope: what and why

Imagine if all parts of your code knew about all the variables in all other parts of your code. You'd have to take great care not to accidentally reuse a variable name in multiple places -- `point` may be an x-y coordinate in one place but lat-long elsewhere, and you'd have to keep that all in mind. Yikes!

Luckily, the visibility of classes, methods, and variables is controlled by what is called **scope**. The things that a particular piece of code can see are called "in scope". Those it cannot are "out of scope".

The ins and outs of scope vary dramatically from language to language. Luckily Objective-C keeps it pretty simple.

# The rules

Essentially there are four rules of scope in Objective-C:

1. Scopes inherit from their parent scope.

    ```objc
    NSInteger x = 2;
    if(x > 1) {
        NSLog(@"I know what x is! It's %d.", x);  // The x from the outer scope is available
        if(x >= 2) {
            NSLog(@"I also know what x is! It's still %d.", x);  // all the way down
        }
    }
    ```
    
2. Curly braces open a new scope

    ```objc
    if(2 < 4) {
        NSInteger x = 5;
    }
    
    NSLog(@"x? What's x? Is it %d?", x);  // Compiler error: "Use of undeclared identifier 'x'"
    ```
    
    (*A technical aside* -- it is totally legal to open your own scopes outside of the context of any flow stuff just by adding curly braces around some code. It’s just a little weird, and should probably be taken as a sign that your method is getting too complicated.)

3. If a scope is introduced by a statement of some kind (`if`, `while`, `for`, a method definition), and that statement has variable definitions in it, those variables are also scoped to that new block.

    ```objc
    NSArray *myArray = @[ @"hello", @"world" ];
    for(NSUInteger i = 0; i < myArray.count; i++) {
        NSLog(@"myArray[%lu] is %@", i, myArray[i]);  // i is in scope here
    }
    
    NSLog(@"After the loop, i is %lu", i);  // But not here! Compiler error.
    ```

4. Code outside of a scope (e.g., at the top of a file) is available across the whole file. This includes definitions of classes and methods, and the contents of `#import`ed things.


Classes have a few small additions, most of which you've already seen:

1. Instance variables from a class are available across all its methods, as is `self`.
2. Methods inside a class are available from all other methods in that class, regardless of the order in which they are declared.


### Shadowing

So, what happens if we try to reuse a variable name we inherited from an outer scope? Let's see:

```objc
NSInteger x = 2;
if(x > 1) {
     NSInteger x = 5;   // this x “shadows” the outer x above; it is independent but has the same name.
     NSLog(@“x in the if statement: %d”, x);  // prints 5
}

NSLog(@“x after the if statement: %d”, x);  // prints 2
```

It worked! Re-declaring a variable already defined in a parent scope is called **shadowing**. Shadowing is dangerous and confusing. If one part of your code was expecting the outer scope’s value (or type!) for the variable name -- well, bad things will happen. You will probably get a compiler warning if you shadow a variable. **Don't do this.**

Note though that shadowing is only possible with variables from *outer* scopes. Trying to redefine a variable in the same scope is an error:

```objc
NSInteger x = 1;
NSLog(@"first x: %d", x);

NSInteger x = 3;  // Compiler error: "Redefinition of x"
NSLog(@"second x: %d", x);
```

# Arguments, scope, values and references, and you

We can view method arguments as a way to get values from one scope into the scope of another function. Let's look at how arguments and scope interact:

```objc
-(NSInteger)squareOfInteger:(NSInteger)anInteger
{
     anInteger = anInteger * anInteger;  // a slightly weird, but legal thing — you can use arguments as any other variable. but what does it mean?
     return anInteger;  // returns 25
}

-(void)main
{
     NSInteger x = 5;
     NSInteger y = [self squareOfInteger:x];
     // y is now 25, but what is x?!
}
```

`squareOfInteger` has its own scope (curly braces -- rule #2!). It also does not inherit `main`’s scope (they’re not nested, and couldn’t be). So, `anInteger` in `squareOfInteger` is effectively a totally different thing than the `x` in `main`. Its value is assigned by the the act of passing it as an argument.

This is **"pass by value”** — all we transmit when we call a method is the *value* of the variable we pass. Methods can change the value of the argument, but the code has no way to relate that value back to the original variable at the call site. So, `x` is still 5 at the end of `main`.

### Objects and pass by value

What does pass by value mean for object instances? What do you think the code below does?

```objc
-(void)addInteger:(NSInteger)i toArray:(NSMutableArray *)array
{
    [array addObject:@(i)];
}

-(void)main
{
    NSMutableArray *myArray = [[NSMutableArray alloc] init];
    [self addInteger:5 toArray:myArray];
    NSLog(@"myArray now has %lu element(s)", myArray.count);
}
```

You may be in for a shock -- the output is "myArray now has 1 element(s)"! I know, I know. You just read about how there's this scope stuff and pass-by-value, but I promise this makes total sense.

The `*` in object types is for “pointer”, which essentially means the *value* of variables of that type is a **reference** to an instance. So, when we pass an object to a method, the method actually does get the *same reference* as our original variable (since that reference is the value). So, calling mutating methods on an object argument (e.g. an `NSMutableArray`) in a method will do the expected thing, and mutate the original (and only) array!

So, how about this:

```objc
-(void)removeAllElementsFromArray:(NSMutableArray *)array
{
    array = [[NSMutableArray alloc] init];
}

-(void)main
{
    NSMutableArray *myArray = [[NSMutableArray alloc] init];
    [myArray addObject:@"hello"];
    [myArray addObject:@"world"];
    
    [self removeAllElementsFromArray:myArray];
}
```

Do you think `-removeAllElementsFromArray:` works as expected?

### Pointers

*(This section has no real bearing on the lab, but if you ever see two asterisks in a data type, or a primitive type with an asterisk, come back here as a jumping-off point. This gets a bit more advanced, so if it doesn't entirely make sense right now just move on to the assignment.)*

If you want to mutate primitives from a function, well… you need a pointer to the primitive. It's the same deal as objects — a value that is a reference to a primitive. The array block methods that have `BOOL *stop` arguments are [an example](https://developer.apple.com/library/prerelease/ios/documentation/Cocoa/Reference/Foundation/Classes/NSArray_Class/index.html#//apple_ref/occ/instm/NSArray/indexesOfObjectsPassingTest:).

And if you want to really reassign an object parameter? Pointers to pointers. `NSError **` arguments are the only time you're likely to see these.

You should very rarely have to deal with things like those. 99% of the time you do, it will be the `NSError **` or `BOOL *` case, which you can just treat as opaque patterns if you don’t feel like learning the ins and outs of pointers. They’re incredibly powerful but frequently confusing and error-prone. The good news is that if you stick within the Objective-C world of classes and methods, you’ll rarely have to deal with them except in name only.


# Assignment:

1. Write a method that takes a mutable array and a string as parameters. It should return the array with the string added, but *must not modify* the original array. (Hint: you'll need some way to create a *copy* of the incoming array.)

2. Write a method that takes an array and returns the number of elements in the array that are in all caps. You’ll need a `for` loop, but think about how the scope will work such that your count variable is available at the end of the method.

3. Rewrite `-removeAllElementsFromArray:` from the example above so that it actually works.

Write these methods in your app delegate. See the app delegate header or the tests for the appropriate method names.
