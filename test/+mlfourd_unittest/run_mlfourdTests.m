setenv('NO_INTERNAL_LOGGER', '1')

run(mlpipeline_unittest.Test_StudyDataSingleton)
run(mlpipeline_unittest.Test_SessionData)

run(mlfourd_unittest.Test_NIfTIc)
run(mlfourd_unittest.Test_NIfTId)
run(mlfourd_unittest.Test_NumericalNIfTId)
run(mlfourd_unittest.Test_MaskingNIfTId)
run(mlfourd_unittest.Test_BlurringNIfTId)
run(mlfourd_unittest.Test_DynamicNIfTId)
run(mlfourd_unittest.Test_ImagingContext) % long
run(mlfourd_unittest.Test_InnerCellComposite)
run(mlpatterns_unittest.Test_CellComposite)
run(mlpipeline_unittest.Test_Logger)
run(mlpipeline_unittest.Test_SessionData)
run(mlpipeline_unittest.Test_StudyDataSingletons)
run(mlio_unittest.Test_ConcreteIO)
run(mlio_unittest.Test_AbstractIO)
run(mlio_unittest.Test_TextParser)
run(mlio_unittest.Test_TextIO)
run(mlio_unittest.Test_IOInterface)

run(mlfourd_unittest.Test_NIfTI)
run(mlcaster_unittest.Test_CasterContext)
run(mlcaster_unittest.Test_CasterStrategy)

%run(mlfourd_unittest.Test_LoggingNIfTId)
%run(mlfourd_unittest.Test_ImagingArrayList)