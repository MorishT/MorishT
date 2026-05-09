With the rise of social media, the internet is now filled with posts written with many different intents.
Technologies for analyzing those intents are increasingly important for building healthy and safe online spaces.

We participated in multiple tasks at the international competition **SemEval 2020**, including tasks on intent analysis.
One example asked a language model to assess how funny an edited news headline was.

Our approach started by extending state-of-the-art language models with task-specific architectures.
For the humor task, we fed both the original and edited sentences into the model and used an added cross-attention layer to compare them.
We then built ensembles of multiple models according to our own recipe and achieved high accuracy.
As a result, we won **first place in multiple tasks**.

Accurate intent analysis also requires understanding the semantic structure of sentences.
We therefore participated in the **CoNLL 2020 Shared Task**, which focused on semantic parsing, and won first place there as well.

These experiences later deepened our interest in ensemble learning and led to one of our subsequent research themes.
