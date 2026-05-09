The ability to follow logic step by step is one of the foundations of human intellectual activity.
Large language models can generate fluent text from vast amounts of knowledge, but can they reason in a logically correct way?

We study how to teach logical reasoning to LLMs.
As a starting point, we organized the characteristics of logical reasoning by drawing on symbolic logic and related fields.
In logical reasoning, new facts are derived by applying inference rules, for example deriving `B` from the facts `A` and `if A then B`.
There are many such rules, but many can be derived from a small set of more fundamental ones.

Based on this view, we designed **logical-reasoning problems for LLMs**.
Starting from given facts, the model applies fundamental inference rules one step at a time until it reaches the final answer.
By instantiating `A` and `B` with many different facts, the model can also learn the generality of the rules themselves.

We then developed an **automatic generation algorithm** that can produce large numbers of such problems.
It first constructs the skeleton of a problem by stacking inference rules over multiple steps and then generates concrete facts using vocabularies and natural-language templates.

Training LLMs on the generated problems led to substantial gains on logical-reasoning tasks.
We also observed improvements on broader reasoning tasks such as mathematics, science, and coding.
We believe this is because logical reasoning forms a foundation for many kinds of reasoning.

This project has continued since around 2022.
In addition to training data, we are also developing benchmarks for evaluating the reasoning capabilities of LLMs.
Our goal is not merely plausible answers, but genuinely correct reasoning.
