//
//  RootViewController.m
//  InfiniteScroll
//
//  Created by Paulo Rodrigues on 2/24/14.
//  Copyright (c) 2014 Riabox. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()
@property (nonatomic, retain) Connect *connect;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic) int page;
@property (nonatomic) BOOL isLoading;
@end

@implementation RootViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Começamos na página 1
    self.page = 1;
    
    // Indica que está sendo realizado uma requisição
    self.isLoading = YES;
    
    // Criamos o indicador para incluir no rodapé da tabela e inicia a animação
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 30.0f)];
    [self.loadingIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.loadingIndicator startAnimating];
    
    // Inicia o array que irá conter as informações da tabela
    self.data = [NSMutableArray array];
    
    // Inicia a classe de conexão, indicando os métodos para sucesso e erro que iremos implementar abaixo
    self.connect = [[Connect alloc] initWithDelegate:self
                                           onSuccess:@selector(responseSuccess:)
                                             onError:@selector(responseError:)];
    
    // Faz a requisição passando como parâmetro a página desejada
    [self.connect requestPage:self.page];
}

- (void)responseSuccess:(id)result {
    // A próxima requisição será feita para a próxima página
    self.page++;
    
    // Indica que não há requisição atualmente e finaliza a animação do rodapé
    [self setIsLoading:NO];
    [self.loadingIndicator stopAnimating];

    // Estes dois blocos são ilustrativos, pois eu simplesmente vou preencher a tabela com uma string qualquer, sempre com 20 elementos cada página
    // Aqui você deverá receber o resultado de sua requisição, seja JSON ou XML e tratá-lo de acordo com sua implementação
    int count = [self.data count];
    
    for (int i = count; i < (count + 20); i++) {
        [self.data addObject:[NSString stringWithFormat:@"Item %d", i]];
    }
    
    // Atualiza os dados da tabela
    [self.tableView reloadData];
}

- (void)responseError:(NSString *)error {
    // Indica que não há requisição atualmente e finaliza a animação do rodapé
    [self setIsLoading:NO];
    [self.loadingIndicator stopAnimating];

    // Mostra no console o erro, que deve ser tratado em sua classe de conexão
    NSLog(@"%@", error);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Obtém a posição da coordenada Y em relação ao scoll da tabela
    NSInteger currentOffset = scrollView.contentOffset.y;
    
    // Quanto Y valerá ao atingir o rodapé da tabela
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    // Não fazer nada caso não tenha atingido o rodapé
    if (maximumOffset - currentOffset > 1.0)
        return;
    
    // Caso atinga o rodapé da página, verificar se não existe uma requisição sendo processada, assim podemos prosseguir
    if (!self.isLoading) {
        // Faz uma requisição passando a página
        [self.connect requestPage:self.page];

        // Indica que uma requisição está sendo realizada
        [self setIsLoading:YES];
        [self.loadingIndicator startAnimating];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [cell.textLabel setText:[self.data objectAtIndex:[indexPath row]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return self.loadingIndicator;
}

@end
