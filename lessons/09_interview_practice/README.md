# 09 — Interview practice

This chapter is for explanation, not memorization.

## A strong answer shape

For most design-verification questions, answer in this order:

1. **What:** define the construct in one sentence.
2. **Why:** name the problem it solves.
3. **How:** explain the important language or scheduler behavior.
4. **Where:** give one real verification use.
5. **Example:** show or describe the smallest useful case.
6. **Trap:** mention one boundary that proves you understand it.

Example:

> “A virtual interface is a class variable that refers to an elaborated interface instance. Classes do not have module-style ports, so the handle lets a driver or monitor access DUT signals. The environment assigns the concrete instance during setup. I check it for null before run time. It does not create another interface or another set of signals.”

That answer is short, but it covers definition, reason, mechanism, use, and a common mistake.

## Practice files

- [Questions and answers](questions_and_answers.md) contains concise spoken answers and follow-ups.
- [Debugging exercises](debugging_exercises.md) asks you to diagnose scheduler, handle, constraint, assertion, and coverage problems.

## How to use this chapter

1. Read only the question.
2. Answer aloud in under ninety seconds.
3. Compare structure, not exact wording.
4. Add one example from a project you actually understand.
5. Answer the follow-up without restarting the full definition.

## What interviewers usually test

The first question checks vocabulary. The follow-up checks whether the vocabulary connects to simulator behavior.

For example:

- “What is nonblocking assignment?” checks definition.
- “When does its right-hand side evaluate?” checks scheduling.
- “What happens if two always_ff blocks depend on each other?” checks whether you can apply that scheduling model.

## Honest project explanation

Say exactly what was run.

- Good: “I ran the portable suite with Verilator and prepared the full covergroup path for Xcelium.”
- Weak: “Everything is verified” when no coverage database or simulator transcript exists.

In a technical discussion, precise boundaries increase credibility.

## Final revision checklist

- I can draw packed versus unpacked dimensions.
- I can explain active and NBA scheduling without saying only “parallel.”
- I can show why handle assignment aliases an object.
- I check the return value of randomize.
- I know when an event notification can be lost.
- I can explain a clocking block from the sampling point of view.
- I can translate one English timing rule into SVA.
- I know why assertion coverage and functional coverage are different.
- I can trace one transaction from generator to scoreboard.
