---
title: "Validation In Go Programming Language"
date: 2024-05-19T15:48:02+02:00
summary: "In this post I show how to validate data in Go `struct` using two approaches: with the help of standard library only and with a third-party library."
draft: false
toc: false
images:
tags:
  - Go
  - Golang
  - Validation
---
## Introduction

Validation is an essential step when working with user input. Data validation ensures that the data is correct and the values are within expected constraints and/or have right format. Moreover, validation may help us prevent errors and assure consistency of the stored information. If the data is used in machine learning (or other areas that require accurate data), it is even more important to verify the correctness of data. Otherwise we may get inaccurate results.

## How To Validate Data Only Using Standard Library

In theory, you could create a `isValid()` method for each `struct` like this:

```go
type Person struct {
  Name    string
  Surname string
  Age     int
  // Other fields
}

func (p Person) IsValid() error {
  if len(p.Name) <= 0 || 64 <= len(p.Name) {
    return errors.New("Name can not be empty or longer than 64 characters!")
  }

  if len(p.Surname) <= 0 || 64 <= len(p.Surname) {
    return errors.New("Surname can not be empty or longer than 64 characters!")
  }

  if p.Age < 0 || 120 <= p.Age {
    return errors.New("Age can not be negative or greater than 120!")
  }

  // Other checks

  return nil
}
```

But this is cumbersome and not the idiomatic way of writing Go code. Moreover, you will write a lot of duplicate code. It would be better to write a `Validator` that will keep track of an error and it will implement functions for validating.

```go
type Person struct {
  Name    string
  Surname string
  Age     int
  // Other fields
}

type Validator struct {
  err error
}

func (v *Validator) MustBeGreaterThan(label string, high, value int) *Validator {
  if v.err != nil {
    return v
  }
  if value <= high {
    v.err = fmt.Errorf("%s must be greater than %d", label, high)
  }
  return v
}

func (v *Validator) MustBeLesserThan(label string, low, value int) *Validator {
  if v.err != nil {
    return v
  }
  if low <= value {
    v.err = fmt.Errorf("%s must be lesser than %d", label, low)
  }
  return v
}

func (v *Validator) MustNotBeEmpty(label string, value string) *Validator {
  if v.err != nil {
    return v
  }
  if value == "" {
    v.err = fmt.Errorf("%s must not be empty", label)
  }
  return v
}

func (v *Validator) MustNotBeLongerThan(label string, length int, value string) *Validator {
  if v.err != nil {
    return v
  }
  if length <= len(value) {
    v.err = fmt.Errorf("%s must not be longer than %d", label, length)
  }
  return v
}

func (v *Validator) MustBeLongerThan(label string, length int, value string) *Validator {
  if v.err != nil {
    return v
  }
  if len(value) <= length {
    v.err = fmt.Errorf("%s must be longer than %d", label, length)
  }
  return v
}

func (v *Validator) IsValid() bool {
  return v.err == nil
}

func (v *Validator) Error() error {
  return v.err
}
```

The `Validator` can be used like this:

```go
func main() {
  validator := new(Validator)
  person := new(Person)

  validator.
    MustBeGreaterThan("Age", 0, person.Age).
    MustBeLesserThan("Age", 120, person.Age).
    MustNotBeEmpty("Name", person.Name).
    MustNotBeEmpty("Surname", person.Surname).
    MustBeLongerThan("Name", 0, person.Name).
    MustNotBeLongerThan("Name", 64, person.Name).
    MustBeLongerThan("Surname", 0, person.Surname).
    MustNotBeLongerThan("Surname", 64, person.Surname)

  if validator.IsValid() {
    fmt.Println("Valid data :)")
  } else {
    fmt.Println("Invalid data :(")
    fmt.Println(validator.Error())
  }
}
```

You can play with this code at [Go Playground](https://go.dev/play/p/KQyXU7xqZmP).

Alternatively, we could also extract the validation into `IsValid()` function of the `Person` type:

```go
func (person *Person) IsValid() (bool, error) {
  validator := new(Validator)

  validator.
    MustBeGreaterThan("Age", 0, person.Age).
    MustBeLesserThan("Age", 120, person.Age).
    MustNotBeEmpty("Name", person.Name).
    MustNotBeEmpty("Surname", person.Surname).
    MustBeLongerThan("Name", 0, person.Name).
    MustNotBeLongerThan("Name", 64, person.Name).
    MustBeLongerThan("Surname", 0, person.Surname).
    MustNotBeLongerThan("Surname", 64, person.Surname)

  return validator.IsValid(), validator.Error()
}
```

## How To Validate Data Using A Library

It seems that Go community is in general reluctant to use third-party libraries (mostly because you can do the majority of common tasks with Standard library and nothing else). However, some gophers have no such restraints and may install a library for whatever reason.

I will show an example that uses [go-validator/validator library](https://github.com/go-validator/validator), which unlike our example uses Go tags. Why this specific one? Well, I googled for a couple of minutes and found this one first 😁 Of course there are other options. A non-exhaustive list includes:
- [ozzo-validation](https://go-ozzo.github.io/ozzo-validation/)
- [go-playground/validator](https://github.com/go-playground/validator)
- [asaskevich/govalidator](https://github.com/asaskevich/govalidator)

The last two have similar interface that looks similar to the [go-validator/validator library](https://github.com/go-validator/validator) and use `struct` tags.

```go
import (
  "fmt"
	"gopkg.in/validator.v2"
)

type Person struct {
  Name    string `validate:"nonzero,min=0,max=64"`
  Surname string `validate:"nonzero,min=0,max=64"`
  Age     int    `validate:"nonzero,min=0,max=120"`
  // Other fields
}

func main() {
  person := new(Person)

  if err := validator.Validate(person); err != nil {
    fmt.Println("Invalid data :(")
    fmt.Println(err)
  } else {
    fmt.Println("Valid data :)")
  }
}
```

You can play with this example [here](https://go.dev/play/p/SLtVV_zMF8U).

## Conclusion

In this post I showed how to validate data in your `struct` using the standard library and the third-party library. Both approaches have their advantages and disadvantages. Even a simple validation example is fairly verbose and requires 60 lines of code, and we have not covered all the possible cases. For example, it is common to have emails, dates, and arrays. Implementing them would make the code even longer.

On the other hand, external libraries can have their own limitations and not suit all our needs. Therefor it is necessary to consider all the options and pick the best one.
