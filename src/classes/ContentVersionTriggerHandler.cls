public with sharing class ContentVersionTriggerHandler {
	

	public static void onAfterInsert(List<ContentVersion> contentversions){
		try{
			if((UserInfo.getUserName() != System.Label.OBI_Integration_User_PROD) || (UserInfo.getUserName() != System.Label.OBI_Integration_User_UAT)){
				List<ContentVersion> cv = new List<ContentVersion>();
				Set<Id> contentDocumentIds = new Set<Id>();
				Set<Id> opportunityIds = new Set<Id>();
				List<ContentNote> contentNotes = new List<ContentNote>();
				List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
				Map<Opportunity, List<ContentNote>> opportunityToContentNoteMap = new Map<Opportunity, List<ContentNote>>();

				for(ContentVersion c : contentversions){
					if(c.FileType == 'SNOTE'){
						contentDocumentIds.add(c.ContentDocumentId);
					}
				}

				if(contentDocumentIds.size() > 0){
					contentNotes = [Select Id, Content,CreatedById,CreatedDate,
									IsReadOnly,LastModifiedById,
									LatestPublishedVersionId,OwnerId,Title
									From ContentNote
									Where Id in :contentDocumentIds];

					system.debug('Content Notes:' + contentNotes[0].Content.toString());

					contentDocumentLinks = [Select Id,ContentDocumentId,LinkedEntityId,ShareType,SystemModstamp,Visibility
											From ContentDocumentLink
											Where ContentDocumentId in :contentDocumentIds];

					for(ContentDocumentLink cdl : contentDocumentLinks){
						if(cdl.LinkedEntityId != null){
							opportunityIds.add(cdl.LinkedEntityId);
						}
					}

					List<Opportunity> opps = new List<Opportunity>();

					opps = [Select Id, OBI_Sale_Id__c
							From Opportunity
							Where Id in : opportunityIds];
					Map<Id, Opportunity> contentDocumentLinkIdToOpportunityMap = new Map<Id, Opportunity>();
					if(opps.size() > 0){
						for(Opportunity o : opps){
							for(ContentDocumentLink cdl : contentDocumentLinks){
								if(o.Id == cdl.LinkedEntityId){
									contentDocumentLinkIdToOpportunityMap.put(cdl.ContentDocumentId, o);
								}
							}
						}


						for(Id i : contentDocumentLinkIdToOpportunityMap.keySet()){
							for(ContentNote cn : contentNotes){
								if(i == cn.Id){
									if(opportunityToContentNoteMap.containsKey(contentDocumentLinkIdToOpportunityMap.get(i)) == false){
										List<ContentNote> cnList = new List<ContentNote>();
										cnList.add(cn);
										opportunityToContentNoteMap.put(contentDocumentLinkIdToOpportunityMap.get(i), cnList);
									}
								}
							}
						}
					}
				}

				if(opportunityToContentNoteMap.size() > 0){
					for(Opportunity o : opportunityToContentNoteMap.keySet()){
						List<ContentNote> notes = new List<ContentNote>();

						notes = opportunityToContentNoteMap.get(o);

						for(ContentNote cn : notes){

							String content = '';

							content += cn.Title + ' - ' ;
							content += cn.Content.toString().stripHtmlTags();

							NoteUtil.createOBIJSONMessageRequest(o.Id, String.valueOf(o.Obi_Sale_Id__c), content, 'NotePost');
						}
					}
				}
			}
		}
		catch(Exception ex){
			System.debug('Error onAfterInsert: ' + ex.getMessage());
		}
	}
}