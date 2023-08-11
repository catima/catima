import Quill from "quill";
import QuillTable from "quill-table";

Quill.register(QuillTable.TableCell);
Quill.register(QuillTable.TableRow);
Quill.register(QuillTable.Table);
Quill.register(QuillTable.Contain);
Quill.register('modules/table', QuillTable.TableModule);
