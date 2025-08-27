import React from 'react';
import ReactSelect from 'react-select';
import Translations from '../Translations/components/Translations';

const ChildChoicesElement = ({ fieldUuid, itemId, defaultValues }) => {
  const childChoices = [
    { value: true, label: Translations.messages['advanced_searches.fields.choice_set_search_field.child_choices_activated_yes'] },
    { value: false, label: Translations.messages['advanced_searches.fields.choice_set_search_field.child_choices_activated_no'] },
  ];

  const isChildChoicesActivated = defaultValues["child_choices_activated"] && defaultValues["child_choices_activated"] === "true";

  const defaultValue = childChoices.find(
    (item) => item.value === isChildChoicesActivated,
  );

  return (
    <ReactSelect
      name={`advanced_search[criteria][${fieldUuid}][${itemId}][child_choices_activated]`}
      options={childChoices}
      classNamePrefix="select"
      placeholder={Translations.messages['advanced_searches.fields.choice_set_search_field.child_choices_activated_placeholder']}
      defaultValue={defaultValue}
    />
  );
};

export default ChildChoicesElement;
