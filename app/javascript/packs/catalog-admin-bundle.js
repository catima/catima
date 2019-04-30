import ReactOnRails from 'react-on-rails';

import DateTimeInput from '../bundles/DateTimeInput/components/DateTimeInput';

import FormattedTextEditor from '../bundles/FormattedTextEditor/components/FormattedTextEditor';

import GeoEditor from '../bundles/GeoEditor/components/GeoEditor';
import GeoBounds from '../bundles/GeoEditor/components/GeoBounds';

import StyleControl from '../bundles/StyleControl/components/StyleControl';
import FontColorButton from '../bundles/StyleControl/components/FontColorButton';
import FontExample from '../bundles/StyleControl/components/FontExample';
import FontMenu from '../bundles/StyleControl/components/FontMenu';
import FontSize from '../bundles/StyleControl/components/FontSize';
import FontStyle from '../bundles/StyleControl/components/FontStyle';

import ReferenceEditor from '../bundles/ReferenceEditor/components/ReferenceEditor';
import SingleReferenceEditor from '../bundles/ReferenceEditor/components/SingleReferenceEditor';
import MultiReferenceEditor from '../bundles/ReferenceEditor/components/MultiReferenceEditor';

import ThumbnailControl from '../bundles/ThumbnailControl/components/ThumbnailControl';

import TranslatedTextField from '../bundles/TranslatedTextField/components/TranslatedTextField';

import ChoiceSetInput from '../bundles/ChoiceSetInput/components/ChoiceSetInput';
import ChoiceSetEditor from '../bundles/ChoiceSetEditor/components/ChoiceSetEditor';

ReactOnRails.register({
  DateTimeInput,
  FormattedTextEditor,
  GeoEditor, GeoBounds,
  StyleControl, FontColorButton, FontExample, FontMenu, FontSize, FontStyle,
  ReferenceEditor, SingleReferenceEditor, MultiReferenceEditor,
  ThumbnailControl,
  TranslatedTextField,
  ChoiceSetInput, ChoiceSetEditor
});
