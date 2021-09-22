import { Ability } from '@casl/ability';

const ability = new Ability([], {
  subjectName(subject) {
    if (subject && subject.subjectType) {
      return subject.subjectType;
    }

    return subject;
  },
});

export default ability;

export const digitalObjectAbility = {
  can: (action, { primaryProject, otherProjects }) => {
    const allProjects = [primaryProject].concat(otherProjects);

    let can = false;
    for (let i = 0; i < allProjects.length; i += 1) {
      if (ability.can(action, { subjectType: 'Project', stringKey: allProjects[i].stringKey })) {
        can = true;
        break;
      }
    }
    return can;
  },
};
