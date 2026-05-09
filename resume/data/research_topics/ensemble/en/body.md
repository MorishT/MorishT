Ensemble learning combines the predictions of multiple models to achieve higher accuracy.
Because it is simple and powerful, it has become one of the most popular techniques in machine learning, and many methods have been proposed over the years.

Even so, ensemble learning has long contained a fundamental question:
**what determines the performance of an ensemble?**
Answering this question is essential for designing better methods.

We approached this question through theoretical analysis.
We showed that ensemble performance is determined by three elements:
**the accuracy of each individual model, the diversity among models, and the information loss that occurs when combining their predictions (fusion loss).**

High individual accuracy is of course important.
Diversity among models is also valuable because one model can correct the mistakes of another.
Yet when multiple predictions are combined, correct signals can be buried under incorrect ones.
In such cases, information loss becomes large, and the full potential of the ensemble cannot be realized.

To analyze this problem, we focused on **Fano's inequality** from information theory.
Fano's inequality provides a lower bound on the error rate when reconstructing information from noisy observations.
In the ensemble setting, it can be interpreted as a lower bound on ensemble error and thus as a barometer of ensemble performance.
We proved mathematically that this lower bound can be decomposed into the three factors above.

We are now computing these factors for a range of ensemble methods to analyze which methods improve which components.

This project was motivated by our experience of achieving strong results with ensemble methods in international NLP competitions such as SemEval and CoNLL.
