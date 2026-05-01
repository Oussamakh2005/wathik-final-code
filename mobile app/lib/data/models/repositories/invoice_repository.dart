import 'package:hive/hive.dart';
import 'package:wathiq/data/models/invoice_model.dart';

import 'base_repository.dart';

class InvoiceRepository implements BaseRepository<InvoiceModel> {
  final String boxName = 'invoices_box';

  Future<Box<InvoiceModel>> _getBox() async {
    return await Hive.openBox<InvoiceModel>(boxName);
  }

  @override
  Future<List<InvoiceModel>> getAll() async {
    final box = await _getBox();
    return box.values.toList();
  }

  @override
  Future<InvoiceModel?> getById(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  @override
  Future<void> add(InvoiceModel item) async {
    final box = await _getBox();
    await box.put(item.id, item); // Using custom ID as Hive key
  }

  @override
  Future<void> update(String id, InvoiceModel item) async {
    final box = await _getBox();
    await box.put(id, item);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }
}