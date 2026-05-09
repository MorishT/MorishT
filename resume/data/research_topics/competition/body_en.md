With the rise of social media, the internet is now filled with posts written with a wide range of intentions.
Technologies for analyzing the intentions embedded in such posts are increasingly important for building healthy and safe online spaces.

We participated in multiple tasks in the international competition **SemEval 2020**, which featured problems on intention analysis.
One example was a task where a language model had to assess how funny an edited news headline was.

Our approach started by extending state-of-the-art language models with task-specific architectures.
For the humor task above, we fed both the original and edited sentences into the model and let an added cross-attention layer compare and analyze them.
We then built ensembles of multiple models according to our own recipe and achieved high accuracy.
As a result, we won **first place in multiple tasks**.

Accurate intention analysis also requires understanding the semantic structure of sentences.
We therefore participated in **CoNLL 2020 Shared Task**, which focused on semantic structure parsing, and won first place there as well.

These experiences later deepened our interest in ensemble learning and led to one of our subsequent research themes.
