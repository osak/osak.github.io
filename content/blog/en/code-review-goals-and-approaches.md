---
title: "Code Review: Goals and Approaches"
slug: "code-review-goals-and-approaches"
date: 2020-11-08T16:03:26+09:00
draft: false
---

{{< toc >}}

## Prologue

The advantages of code reviews have long been emphasized. However, in many cases, code reviews are done without understanding the purpose and main focus [6]. Reviews without clearly defined purposes will eventually become a boring, valueless, and time-consuming ritual for just getting an approval stamp.

I even had not really thought about the purpose of code review. I used to simply think that code reviews are necessary to point out mistakes and possible improvements because humans are to make mistakes and carelessly overlook nice solutions. Such a naive understanding would work, and actually had worked, as long as there are not many committers in the project. However, as the number of committers increases, the negative side of not having a clearly written purpose of code reviews gradually becomes a pain. For example: is a tiny improvement worth pointing out in review? How to resolve a conflict when multiple reviewers don’t agree with each other's opinions? What if a code author stubbornly refuses to follow advice from reviewers?

In this article, I will revisit the purpose of code review. Then I will summarize some of the key ideas for achieving that purpose. Some of these insights are based on my own experience, whereas others are borrowed from documents available on the Internet. See appendix for a list of websites and other resources that were particularly helpful in writing this article.

If you would like to read other references in addition to this article, I recommend you to read [Code Review Best Practices](https://medium.com/palantir/code-review-best-practices-19e02780015f) [3] for the first thing. It is a very good summary of the code review process in general and it also covers some details that I omitted in my article. If you have more time, then [eng-practices | How to do a code review](https://google.github.io/eng-practices/review/reviewer/) [1] and [eng-practices | The CL author's guide to getting through code review](https://google.github.io/eng-practices/review/developer/) [2] are also great articles to read.


## The Goal of Code Reviews
### Main Goals

* To ensure that at least one person, who is not the commit author, can maintain the merged code.
* To reach a consensus on the implementation. The consensus includes every aspect of code -  parity between a feature specification and implementation, consistency with existing code, ease of maintenance, coding style, and so on.

The main purpose of the code review is to help other team members understand the code you wrote [1][3][7]. Even the code author often forgets the details of the code after a while and has no choice other than reading the code again. If others have trouble with reading and understanding your code now, it won't be understood even in the future. The code fallen into this status is not only quite difficult to extend but also is a huge debt on the system stability - no one could tell if the code is affected by changes in other places, which means that the code would break while nobody is aware of it.

Unless you choose to accept to give up when the system faces trouble and nobody can read the code causing the problem, at least one other person should understand the changes before merging it. Ideally, every team member should understand it. Code reviewers should be aware that they will eventually have to maintain, modify, or extend the code whenever they write review comments. Therefore, review comments should include questions about the intent of the code, as well as pointing out mistakes and possible improvements.

Note that I’m not suggesting that you should not point out bugs. However, I wouldn’t include bug hunting as a primary objective of code reviews. There are two reasons for this:

* It has been said that bugs make up only 15% of all review comments [5] and that many bugs are missed in reviews [4][5].
* Increasing the coverage of automated tests would be more effective in the medium and long term for capturing bugs.


### Minor Objectives

The concrete way to achieve the major objective depends on various factors including project, team size, and company culture. I suggest one minor objective here, which is likely a part of the major objective in most situations.

The code should not (significantly) reduce the overall reliability of the system.
Google's eng-practices document [1] asserts that "Don't accept CLs that degrade the code health of the system". However, a slight loss of reliability is often acceptable as a trade-off for development velocity. The threshold strongly depends on the culture of the team and the project.
Test coverage and code complexity are indicators of reliability.


## Checklist

When reviewing the code, a checklist is useful to make sure that nothing is overlooked [8]. It should be used with careful attention to the following points:

* Avoid considering checkpoints of lower priority until you have identified all the high priority issues [1].
* The lower priority review comments should look like so. For instance, prepend a comment with [nit] [1][3].
* Even if low-priority review comments are not addressed, consider giving a go-sign taking into account the importance of the feature and time constraints.
  * Low-priority items can usually be fixed later. Conversely, problems that are difficult to fix later should be classified as a high priority.

### High priority
This category consists of the checks for problems that cause major damage or are difficult to fix later.

* Make sure that the requirements and the actual functionality match
* Problems that do not directly appear as failures in the code or tests, such as Inconsistency with the external environment or well known error-prone design. Tricky behavior of external services or security mechanisms are examples of such problems.
* Design or implementation strategies that are empirically known to be difficult to fix up later.
  * Huge classes and functions
  * Well-known better design pattern exists
  * etc.

### Medium priority

* Complexity assessment
  * Can't we replace it with a simple implementation or library?
  * Is the code appropriately commented if it’s difficult to understand?
* Consistency with existing logic
* Evaluation of extensibility
* How likely it will be extended in the future?
* Will we prefer extending the code rather than writing a new code for future updates?
* Finding bugs and edge cases
* Check to see if the test is written.

### Low priority
This category consists of the checks for problems that don't significantly affect the system and can be easily fixed later.

* Coding style
* External documentation


## How to avoid turning reviews into a burden
### Control the size of reviews

Reviewing large changes is burdensome. The larger the scale, the more code that interacts with each other, and the more oversights it causes. Also, a code review with a large number of comments is simply difficult to read. From the code author's perspective, a slow review resulting in a delayed merge is not desirable.

* Reviewers may ask the code author to split the code review into smaller pieces if they feel it is too large [1]. Taking more than 20 minutes to review is a good threshold [3]. Reviews can be often too large for reasons like the following:
* Unrelated changes are accidentally lumped into a single review.
* Refactoring and feature changes are lumped together.
* Implementation strategy or existing code is so poor that forcing the change to be large.

The first one is easy to work around; if you can explain that the changes are unrelated to each other, the author will happily split them up. The second one can be resolved by separating refactoring and feature changes into separate reviews, but some commitments from the code author may be needed because refactoring and feature implementation usually overlap with each other. In general, separately committing, reviewing, and deploying "large-scale refactoring that doesn't change functionality" and "small changes that change functionality" will efficiently reduce the cognitive load of reviewers.

As for the last one, it probably needs to be addressed beyond the context of the code review. If the existing code is so complex that you can't avoid making huge changes, you should consider devoting a certain amount of effort to refactoring. If the implementation strategy is poorly chosen, the code author's skills may be insufficient. In this case, you should consider training the author through other means like 1 on 1 meetings or pair programming. You may also merge the large change believing it’s good, but you must be aware of the risk arising from having the code that is not thoroughly discussed.


### Who should be the reviewer?

In terms of increasing the number of people who understand the code as much as possible, it seems desirable to have everyone involved in the project reviewing it. However, it's neither realistic nor efficient to ask everyone to make time for every single review. Furthermore, the more people involved in the discussion, the more difficult it is to reach a consensus. For these reasons, the desirable number of reviewers will be just one or two [3]. In this case, one reviewer should be a person who has a bird's-eye view of the entire project, such as a tech lead. The other will be a person who is considered to be familiar with the part being changed (e.g., who appears many times in `git blame` of the changed files).

The main reasons for limiting the number of people are, as mentioned earlier, efficiency and ease of discussion. You don’t have to worry about having too many reviewers if you can work around these problems in other ways. For example, reading code as a reviewer can itself serve as an exercise in reading other people's code and is a great opportunity to learn desirable patterns for those unfamiliar with the project and programming itself, so extra reviewers may participate for such purposes. Similarly, having many reviewers won’t particularly complicate the discussion If a formal way to resolve conflicts on reviewers’ opinions is defined and shared across all team members.

### How to organize the discussion

Code only works as you write it. Whether you criticize the code or defend one from criticism, there should be a clear logic and explanation of the advantages and disadvantages. If you can't provide such an explanation to convince the opponent, then you’d better accept what they are saying.

It is not uncommon that every participant in a discussion evaluates the implementation on a slightly different axis, and the discussion gets confused as to whether this one is better or that one is better. When the two or more implementations look equally good so that it’s hard to make a definitive decision based on their pros and cons, the opinion of the code author should be the winner [1]. It is because it’s the easiest and the time-efficient option - since the implementation is already there. Even if the chosen implementation should start to cause a problem in the future, it should not be as hard as fixing it from scratch because the problem is already thoroughly discussed and shared among reviewers via the code review process.

### Criticism and personal offense

The message that "criticism in code reviews is directed at the code, not at the individual" has been emphasized in various places [1][2][3][6]. The purpose is the message is said to improve psychological safety by emphasizing that code review is a logical discussion process that doesn’t have anything to do with the personality of the code author. I wouldn't say this message is a complete deception though, it somewhat sounds like hollow words just designed for public presentation.

Who wrote the code is actually a big piece of information in code reviews. You would confidently trust the code If it’s written by who has changed the same part of the code many times in the past. On the other hand, extra caution needs to be used if it’s the first time for the author to change that part of the code, or if the author has made arguable changes in other reviews. Similarly, the details of review comments can be affected by at whom it is directed. If you know  that the author has a certain level of proficiency, through previous their conversations and commits, you would write a brief comment just explaining the essential idea. However, if the author is junior or less experienced, you'll take the time to write a detailed comment.

Consciously or unconsciously, review comments are more or less customized to the code author. This is not just because code authors are human and need to take sentimental considerations into account, but also because it is the most efficient way to run a discussion. Each person would need a different extent of information to understand the context, rationale, and meaning of the review comments. It's not as simple as saying “stop being personal, just use neutral expressions.”

In addition to these facts from the perspective of reviewers, code authors also have their own reasons for taking comments personally. For programmers, the code they write is tied to their identity to some extent. For example, if the code was written for work, it is directly related to your salary. Also, programs highly reflect the quality of thoughts of the code author. Therefore, as the review comments may be personalized to the code author and the code author may consider their code as a part of their identity, it’s quite natural for code review comments to invoke sentimental feelings (I've discussed this topic in my past entry (written in Japanese; not translated) [9]).

In light of the above discussions, I would suggest a more accurate rephrasing of the message: "Criticism in code reviews is made because the code is logically questionable". Code author’s personality and way of thinking largely affect whether a comment is taken as an offense. Even though some comments might hurt a lot, reviewers aren’t commenting with the intention of ruining the code author in a mess. They are commenting because they wish to have more conversation on the code so that they can convince themselves. Of course, reviewers also should use care and be gentle when they make comments so the code author won’t take it too badly. In particular, reviewers should not speak ill of the code author's habits or abilities (if you feel you have to, tell your manager if you're in an organization. If it's the Internet, simply ignore the problematic individual). The subtleties in code review comments are no different than regular relationships and regular conversations.

## Advice for Reviewers
* Review the design first. Review the coding style later [1].
  * Reviews on the design require more extensive knowledge than the coding style. In other words, the value of the comments on design is relatively high because fewer people could do that.
  * The incorrect design will also affect code written later.
  * Ideally, coding styles should be automatically enforced with linter and auto formatter.
  * Stylistic issues can be refactored later (if it’s not too particular).
* Keep in mind that you are going to maintain the code under review.
  * One of the main goals of code review is to share the knowledge so that no one becomes a single point of failure. You are one of the backups.
  * Make sure you understand the code. Make sure you feel comfortable with maintaining and extending the code.
* Don't impose your ideas.
  * Even If the code is different from how you would write, respect the author’s code unless you can clearly point out a flaw in it [1].
  * The comments like "I would write in this way…” are still valid. Just don’t impose it.
* Criticize the code, not the individual.
  * Avoid referring to the individual code author as much as possible. Instead of saying "You are doing wrongly with writing code," say "This code is not preferable because of problems like...". Instead of saying  "You are thinking in a wrong way so ended up in such a bad design”, say "This design breaks when… so it needs to be revised.”
    * Sometimes the ego of an individual is closely attached to the code they wrote so these are inseparable pieces. It’s best to pay attention to your words.
  * Ways to avoid referring to individual highly depend on the language and the culture. As a general rule, an easy way to avoid such sentences is to make an object a subject of the sentence rather than a person.
* Praise when you find a good design or style.
  * As well as bad patterns, there are good patterns that we should actively pursue. Give a praise to such good patterns.
  * The code author may just happen to write a good pattern without realizing its true value. They can be just trying out a new pattern without deeply looking into how it will contribute to the code quality of the project. If you already know the pattern is good, you can help the author and others efficiently learn the good patterns by sharing your knowledge. Positive comments make the author feel recognized to gain motivation [4].
* Make sure to answer questions from Code author [1][3]
  * Just as reviewers may fail to understand the code or the background, code authors may also fail to understand the review comments because of gaps in knowledge or lack of explanation. Code authors may ask questions to fill in the gaps in such cases. The reviewer, who gets the question back, should answer the question to help the code author understand the real intention.
  * Sometimes you may find that your original comment was wrong after reading the question from the code author. In that case, admit your mistake and clearly tell that your comment was wrong. Don’t try to justify your comment before saying sorry.

## Advice for Code Authors
* Make reviews as small as possible [2][3]
  * The size of the code review should be small to reduce the load on the reviewer. Try to achieve your goals with the smallest possible changes.
  * Encapsulate new code into private functions if possible.
  * Similarly, try to introduce new local variables instead of new fields. Moreover, prefer new functions over new local variables. The more the code is contained, the easier it is to give a go sign even if the code quality is arguable. Reasons:
    * It's easier to confirm that existing behavior won’t break.
    * It’s easier to refactor later.
* Explain the detailed context of the change in a merge request, commit message, ticket, etc.[2]
  * Reviewers often don't know the detailed context or specification of the feature.
  * Reviewers want to know *why* this change is *necessary*. You’d better be able to answer this question in one sentence. If you can't, you might not have a holistic understanding of the problem, or your ticket is too coarsely grained.
* Questions from reviewers aren’t attacks.
  * Reviewers review the code assuming they have to maintain the code.
  * Reviewers ask questions, just as they would do if you gave a talk. There's a lot of thoughts that can't be shared through tickets and codes alone.
  * Always answer the reviewer's questions [1][3]. If you can't answer, either the reviewer's question is wrong or the reviewer knows something that you don't know. In either case, clarify that you *couldn’t get it* and ask for the real intention. 
  * Unless you clarify you couldn’t get the meaning of the question, the reviewer will likely think you fully understood the comment and you write a reply to share your opinion. This will lead to a discrepancy in understanding of the problem and may cause needless conflicts.
* Review comments are not intended to offend you.
  * You probably feel attached to the code you've written to some extent, and you may feel hurt by critical comments. However, the reviewers are not writing comments to purposely hurt you. They are writing just because they think the code will likely cause problems.
    * Very occasionally, one writes a comment to actually offend you. Such cases are more of a communication problem rather than a code review. Deal with them in accordance with the social sanctions (report them to your boss or the organization, or just block and ignore them on GitHub, etc.)
  * If you get a lot of critical comments, you may feel like you are being accused of being less competent.
    * In fact, "less competent" is a correct observation from a certain perspective. The productivity of who receives a large number of review comments is lower than who writes mostly flawless code. Whether you feel mentally burdened about this is a matter of your career vision and expectation setting. If the review comments keep putting a strain on you, talk to your manager or others to seek help.

## References
* [1] [eng-practices | How to do a code review](https://google.github.io/eng-practices/review/reviewer/)
* [2] [eng-practices | The CL author’s guide to getting through code review](https://google.github.io/eng-practices/review/developer/)
* [3] [Code Review Best Practices](https://medium.com/palantir/code-review-best-practices-19e02780015f)
* [4] [Lessons From Google: How Code Reviews Build Company Culture](https://blog.fullstory.com/what-we-learned-from-google-code-reviews-arent-just-for-catching-bugs/)
* [5] [Code Reviews Do Not Find Bugs. How the Current Code Review Best Practice Slows Us Down - Microsoft Research](https://www.microsoft.com/en-us/research/publication/code-reviews-do-not-find-bugs-how-the-current-code-review-best-practice-slows-us-down/?from=http%3A%2F%2Fresearch.microsoft.com%2Fapps%2Fpubs%2F%3Fid%3D242201)
* [6] [コードレビューを成功させるためにCTOが考えるべき7つのこと](https://flxy.jp/article/4298)
* [7] [Why code reviews matter (and actually save time!)](https://www.atlassian.com/agile/software-development/code-reviews)
* [8] [Code review guidelines - CodeProject](https://www.codeproject.com/Articles/524235/Codeplusreviewplusguidelines)
* [9] [クソコード批判とクソコード批判批判はなぜ燃えるのか](https://osak.hatenablog.jp/entry/kuso-code-criticism)
