import { Ability } from '@casl/ability';

export default new Ability([], {
  subjectName(subject) {
    if (subject && subject.subjectType) {
      return subject.subjectType;
    }

    return subject;
  },
});
